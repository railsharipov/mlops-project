#!/usr/bin/env bash
set -Eeuo pipefail

exec > >(tee -a /var/log/startup-script.log) 2>&1

trap 'rc=$?; echo "ERROR: exit=${rc}, line=${LINENO}, command=${BASH_COMMAND}" >&2' ERR

echo "Startup script began: $(date -Is)"

export DEBIAN_FRONTEND=noninteractive

MARKER="/var/lib/bootstrap-complete"

if [[ -f "${MARKER}" ]]; then
  echo "Bootstrap already completed; skipping."
  exit 0
fi

apt-get update
apt-get install -y ca-certificates curl

# Anaconda installation
ANACONDA_INSTALLER="Anaconda3-2026.07-1-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}"

curl -fL "${ANACONDA_URL}" -o "/tmp/${ANACONDA_INSTALLER}"

bash "/tmp/${ANACONDA_INSTALLER}" \
  -b \
  -p /opt/anaconda3

rm -f "/tmp/${ANACONDA_INSTALLER}"

/opt/anaconda3/bin/conda --version

# Docker repository
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

systemctl enable --now docker

docker --version
docker compose version

touch "${MARKER}"

echo "Startup script completed: $(date -Is)"
