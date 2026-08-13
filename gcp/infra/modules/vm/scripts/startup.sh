#!/usr/bin/env bash
set -Eeuo pipefail

exec > >(tee -a /var/log/startup-script.log) 2>&1

trap 'rc=$?; echo "ERROR: exit=${rc}, line=${LINENO}, command=${BASH_COMMAND}" >&2' ERR

echo "Startup script began: $(date -Is)"

export DEBIAN_FRONTEND=noninteractive


META_URL="http://metadata.google.internal/computeMetadata/v1"

PROJECT_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/project/project-id"
)"
TS_SECRET_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/attributes/tailscale-secret-id"
)"
SERVICE_USER="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/attributes/service-user"
)"

# Tailscale installation
if command -v tailscale > /dev/null 2>&1; then
    echo "Tailscale is already installed; skipping installation."
else
    TS_INSTALLER="$(mktemp)"
    curl -fsSL https://tailscale.com/install.sh -o "${TS_INSTALLER}"
    sh "${TS_INSTALLER}"
    rm -f "${TS_INSTALLER}"
fi

# Tailscale bootstrap
TOKEN="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/service-accounts/default/token" \
  | jq -r '.access_token'
)"

TAILSCALE_AUTH_KEY="$(
  curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${TS_SECRET_ID}/versions/latest:access" \
  | jq -r '.payload.data' \
  | base64 --decode
)"

umask 077
TS_AUTH_FILE="$(mktemp)"
printf '%s' "${TAILSCALE_AUTH_KEY}" > "${TS_AUTH_FILE}"

tailscale up --auth-key="file:${TS_AUTH_FILE}"

rm -f "${TS_AUTH_FILE}"
unset TAILSCALE_AUTH_KEY TOKEN
umask 022  # restore default

# Tailscale serve — expose services over Tailscale HTTPS
tailscale serve --bg --https=8888 http://127.0.0.1:8888  # JupyterLab
tailscale serve --bg --https=5000 http://127.0.0.1:5000  # MLflow


apt-get update
apt-get install -y ca-certificates curl jq

# Service user
if id "${SERVICE_USER}" &>/dev/null; then
  echo "User '${SERVICE_USER}' already exists; skipping creation."
else
  useradd --create-home --shell /bin/bash "${SERVICE_USER}"
fi

# Anaconda installation (runs as service user to ensure correct ownership)
ANACONDA_INSTALLER="Anaconda3-2026.07-1-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}"
ANACONDA_PREFIX="/opt/anaconda3"

if [[ -x "${ANACONDA_PREFIX}/bin/conda" ]]; then
  echo "Anaconda already installed at ${ANACONDA_PREFIX}; skipping installation."
else
    # Remove any partial install so the installer starts from a clean slate.
    rm -rf "${ANACONDA_PREFIX}"
    # Pre-create the prefix dir owned by the service user; /opt is root-owned
    # so the installer (running as service user) cannot create it directly.
    install -d -o "${SERVICE_USER}" -g "${SERVICE_USER}" "${ANACONDA_PREFIX}"
    curl -fL "${ANACONDA_URL}" -o "/tmp/${ANACONDA_INSTALLER}"

    sudo -u "${SERVICE_USER}" bash "/tmp/${ANACONDA_INSTALLER}" \
        -bu \
        -p "${ANACONDA_PREFIX}"

    rm -f "/tmp/${ANACONDA_INSTALLER}"

    "${ANACONDA_PREFIX}/bin/conda" --version
fi

# Initialise conda for the service user's shell (idempotent)
sudo -u "${SERVICE_USER}" "${ANACONDA_PREFIX}/bin/conda" init bash

# MLflow installation (runs as service user)
if [[ -x "${ANACONDA_PREFIX}/bin/mlflow" ]]; then
  echo "MLflow already installed; skipping installation."
else
  sudo -u "${SERVICE_USER}" "${ANACONDA_PREFIX}/bin/pip" install --quiet \
    mlflow \
    psycopg2-binary \
    google-cloud-storage
  "${ANACONDA_PREFIX}/bin/mlflow" --version
fi

# Docker installation
if command -v docker > /dev/null 2>&1 \
  && docker compose version > /dev/null 2>&1; then

  echo "Docker and Docker Compose are already installed; skipping installation."

else
  echo "Installing Docker..."

  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

  chmod a+r /etc/apt/keyrings/docker.asc

  tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt-get update

  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
fi

# Docker daemon bootstrap
systemctl enable --now docker
docker --version
docker compose version

# Add service user to the docker group now that Docker is installed
usermod -aG docker "${SERVICE_USER}"

# ---------------------------------------------------------------------------
# MLFlow service
# ---------------------------------------------------------------------------

# Helper script: fetches PGPASSWORD and GCP_BUCKET at every service start
# and writes them to an EnvironmentFile consumed by mlflow.service.
cat > /usr/local/bin/mlflow-fetch-env.sh << 'HELPER_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

META_URL="http://metadata.google.internal/computeMetadata/v1"

TOKEN="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/service-accounts/default/token" \
  | jq -r '.access_token'
)"

PROJECT_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/project/project-id"
)"
GCP_BUCKET="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/attributes/gcp-bucket"
)"
PG_SECRET_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/attributes/pg-secret-id"
)"

PGPASSWORD="$(
  curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${PG_SECRET_ID}/versions/latest:access" \
  | jq -r '.payload.data' \
  | base64 --decode
)"

install -m 0600 /dev/null /run/mlflow/env
printf 'PGPASSWORD=%s\nGCS_ARTIFACT_ROOT=gs://%s\n' "${PGPASSWORD}" "${GCP_BUCKET}" > /run/mlflow/env
HELPER_EOF
chmod 0755 /usr/local/bin/mlflow-fetch-env.sh

cat > /etc/systemd/system/mlflow.service << SERVICE_EOF
[Unit]
Description=MLflow Tracking Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SERVICE_USER}
RuntimeDirectory=mlflow
ExecStartPre=/usr/local/bin/mlflow-fetch-env.sh
EnvironmentFile=-/run/mlflow/env
ExecStart=/opt/anaconda3/bin/mlflow server \\
    --host 127.0.0.1 \\
    --port 5000 \\
    --allowed-hosts '*.ts.net:5000' \\
    --backend-store-uri "postgresql+psycopg2://mlops@postgres.internal.mlops.net:5432/mlops" \\
    --default-artifact-root \\
    \$GCS_ARTIFACT_ROOT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# ---------------------------------------------------------------------------
# JupyterLab service
# ---------------------------------------------------------------------------

# Helper script: fetches the Jupyter token at every service start and writes
# it to an EnvironmentFile consumed by jupyterlab.service.
cat > /usr/local/bin/jupyterlab-fetch-env.sh << 'HELPER_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

META_URL="http://metadata.google.internal/computeMetadata/v1"

TOKEN="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/service-accounts/default/token" \
  | jq -r '.access_token'
)"

PROJECT_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/project/project-id"
)"
JUPYTER_TOKEN_SECRET_ID="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/attributes/jupyter-token-secret-id"
)"

JUPYTER_TOKEN="$(
  curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${JUPYTER_TOKEN_SECRET_ID}/versions/latest:access" \
  | jq -r '.payload.data' \
  | base64 --decode
)"

install -m 0600 /dev/null /run/jupyterlab/env
printf 'JUPYTER_TOKEN=%s\n' "${JUPYTER_TOKEN}" > /run/jupyterlab/env
HELPER_EOF
chmod 0755 /usr/local/bin/jupyterlab-fetch-env.sh

cat > /etc/systemd/system/jupyterlab.service << SERVICE_EOF
[Unit]
Description=JupyterLab Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=/home/${SERVICE_USER}
RuntimeDirectory=jupyterlab
Environment=PATH=/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStartPre=/usr/local/bin/jupyterlab-fetch-env.sh
EnvironmentFile=-/run/jupyterlab/env
ExecStart=/opt/anaconda3/bin/jupyter lab \\
    --no-browser \\
    --ip=127.0.0.1 \\
    --port=8888 \\
    --ServerApp.allow_remote_access=True
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable --now mlflow.service
systemctl enable --now jupyterlab.service


echo "Startup script completed: $(date -Is)"
