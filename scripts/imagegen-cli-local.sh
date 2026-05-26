#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
LAUNCHER="$CODEX_HOME/bin/imagegen-cli"

if [[ ! -x "$LAUNCHER" ]]; then
  echo "error: imagegen launcher not found or not executable: $LAUNCHER" >&2
  echo "Set up ~/.codex/bin/imagegen-cli and the matching ~/.codex image config files on this machine first." >&2
  exit 1
fi

exec "$LAUNCHER" "$@"
