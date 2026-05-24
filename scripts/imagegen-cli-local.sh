#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG_FILE="${CODEX_CONFIG_FILE:-$CODEX_HOME/config.toml}"
LAUNCHER="$CODEX_HOME/bin/imagegen-cli"

if [[ ! -x "$LAUNCHER" ]]; then
  echo "error: imagegen launcher not found or not executable: $LAUNCHER" >&2
  echo "Set up ~/.codex/bin/imagegen-cli and ~/.codex/imagegen.env on this machine first." >&2
  exit 1
fi

BASE_URL="${OPENAI_BASE_URL:-}"
if [[ -z "$BASE_URL" && -f "$CONFIG_FILE" ]]; then
  BASE_URL="$(awk -F'\"' '/base_url/ {print $2; exit}' "$CONFIG_FILE")"
fi

if [[ -z "$BASE_URL" ]]; then
  exec "$LAUNCHER" "$@"
fi

OPENAI_BASE_URL="$BASE_URL" exec "$LAUNCHER" "$@"
