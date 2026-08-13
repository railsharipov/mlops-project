#!/usr/bin/env bash
set -Eeuo pipefail

META_URL="http://metadata.google.internal/computeMetadata/v1"

TOKEN="$(
  curl -fsS \
    -H "Metadata-Flavor: Google" \
    "${META_URL}/instance/service-accounts/default/token" \
  | jq -r '.access_token'
)"

PROJECT_ID="$(curl -fsS -H "Metadata-Flavor: Google" "${META_URL}/project/project-id")"
JUPYTER_TOKEN_SECRET_ID="$(curl -fsS -H "Metadata-Flavor: Google" "${META_URL}/instance/attributes/jupyter-token-secret-id")"

export JUPYTER_TOKEN="$(
  curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${JUPYTER_TOKEN_SECRET_ID}/versions/latest:access" \
  | jq -r '.payload.data' \
  | base64 --decode
)"

exec /opt/anaconda3/bin/jupyter lab \
    --no-browser \
    --ip=127.0.0.1 \
    --port=8888 \
    --ServerApp.allow_remote_access=True
