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
GCP_BUCKET="$(curl -fsS -H "Metadata-Flavor: Google" "${META_URL}/instance/attributes/gcp-bucket")"
PG_SECRET_ID="$(curl -fsS -H "Metadata-Flavor: Google" "${META_URL}/instance/attributes/pg-secret-id")"
TAILNET_DOMAIN="$(curl -fsS -H "Metadata-Flavor: Google" "${META_URL}/instance/attributes/tailnet-domain")"

export PGPASSWORD="$(
  curl -fsS \
    -H "Authorization: Bearer ${TOKEN}" \
    "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${PG_SECRET_ID}/versions/latest:access" \
  | jq -r '.payload.data' \
  | base64 --decode
)"

PORT=5000

exec /opt/anaconda3/bin/mlflow server \
    --host 127.0.0.1 \
    --allowed-hosts "127.0.0.1:${PORT},localhost:${PORT},*.${TAILNET_DOMAIN}:${PORT}" \
    --port "${PORT}" \
    --backend-store-uri "postgresql+psycopg2://mlops@postgres.internal.mlops.net:5432/mlops" \
    --artifacts-destination "gs://${GCP_BUCKET}" \
    --cors-allowed-origins "https://*.${TAILNET_DOMAIN}:${PORT},http://localhost:${PORT},http://127.0.0.1:${PORT}"
