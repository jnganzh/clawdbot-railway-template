#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/google /data/.config/gws /data/npm /data/npm-cache /data/pnpm /data/pnpm-store /data/workspace

# Persist Google ADC credentials from Railway env
if [ -n "${GOOGLE_APPLICATION_CREDENTIALS_JSON:-}" ]; then
  printf '%s' "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /data/google/application_default_credentials.json
  chmod 600 /data/google/application_default_credentials.json
fi

# Persist gws OAuth client config from Railway env
if [ -n "${GOOGLE_WORKSPACE_CLI_CLIENT_SECRET_JSON:-}" ]; then
  printf '%s' "$GOOGLE_WORKSPACE_CLI_CLIENT_SECRET_JSON" > /data/.config/gws/client_secret.json
  chmod 600 /data/.config/gws/client_secret.json
fi

# Clean broken gws encrypted creds/cache so ADC fallback works reliably
rm -f /data/.config/gws/credentials.enc
rm -f /data/.config/gws/credentials.json
rm -f /data/.config/gws/token_cache.json

# Make gws + Google libs look in the persistent volume
export HOME=/data
export GOOGLE_APPLICATION_CREDENTIALS=/data/google/application_default_credentials.json

# Install gws if missing (persistent npm prefix already points at /data/npm)
if ! command -v gws >/dev/null 2>&1; then
  npm install -g @googleworkspace/cli
fi
