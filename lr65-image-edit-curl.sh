#!/usr/bin/env bash

set -euo pipefail

load_env_var() {
  local key="$1"
  local env_file="${2:-.env}"
  local line value

  [[ -f "$env_file" ]] || return 1

  line="$(grep -E "^[[:space:]]*(export[[:space:]]+)?${key}[[:space:]]*=" "$env_file" | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1

  value="${line#*=}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  if [[ "${value:0:1}" == "\"" && "${value: -1}" == "\"" ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
    value="${value:1:${#value}-2}"
  fi

  printf '%s' "$value"
}

load_auth_json_var() {
  local key="$1"
  local auth_file="${2:-$HOME/.codex/auth.json}"
  local line value

  [[ -f "$auth_file" ]] || return 1

  line="$(grep -E "\"${key}\"[[:space:]]*:" "$auth_file" | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1

  value="$(printf '%s\n' "$line" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
  [[ -n "$value" ]] || return 1

  printf '%s' "$value"
}

load_toml_root_var() {
  local key="$1"
  local config_file="${2:-$HOME/.codex/config.toml}"

  [[ -f "$config_file" ]] || return 1

  awk -v key="$key" '
    /^[[:space:]]*\[/ { exit }
    {
      pattern = "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*\""
      if ($0 ~ pattern) {
        value = $0
        sub(pattern, "", value)
        sub(/".*$/, "", value)
        print value
        exit
      }
    }
  ' "$config_file"
}

load_toml_project_var() {
  local key="$1"
  local project_path="$2"
  local config_file="${3:-$HOME/.codex/config.toml}"
  local section="[projects.\"${project_path}\"]"

  [[ -f "$config_file" ]] || return 1

  awk -v key="$key" -v section="$section" '
    $0 == section { in_target = 1; next }
    /^[[:space:]]*\[/ { in_target = 0 }
    in_target {
      pattern = "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*\""
      if ($0 ~ pattern) {
        value = $0
        sub(pattern, "", value)
        sub(/".*$/, "", value)
        print value
        exit
      }
    }
  ' "$config_file"
}

load_codex_project_var() {
  local key="$1"
  local config_file="${2:-$HOME/.codex/config.toml}"
  local search_dir="${3:-$PWD}"
  local value=""

  while true; do
    value="$(load_toml_project_var "$key" "$search_dir" "$config_file" || true)"
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return 0
    fi

    [[ "$search_dir" == "/" ]] && break
    search_dir="$(dirname "$search_dir")"
  done

  return 1
}

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  OPENAI_API_KEY="$(load_env_var OPENAI_API_KEY .env || true)"
  OPENAI_API_KEY="${OPENAI_API_KEY:-$(load_auth_json_var OPENAI_API_KEY || true)}"
  export OPENAI_API_KEY
fi

if [[ -z "${OPENAI_IMAGE_API_KEY:-}" ]]; then
  OPENAI_IMAGE_API_KEY="$(load_env_var OPENAI_IMAGE_API_KEY .env || true)"
  OPENAI_IMAGE_API_KEY="${OPENAI_IMAGE_API_KEY:-$(load_auth_json_var OPENAI_IMAGE_API_KEY || true)}"
  export OPENAI_IMAGE_API_KEY
fi

if [[ -z "${OPENAI_BASE_URL:-}" ]]; then
  OPENAI_BASE_URL="$(load_env_var OPENAI_BASE_URL .env || true)"
  OPENAI_BASE_URL="${OPENAI_BASE_URL:-$(load_codex_project_var base_url || true)}"
  OPENAI_BASE_URL="${OPENAI_BASE_URL:-$(load_toml_root_var base_url || true)}"
  OPENAI_BASE_URL="${OPENAI_BASE_URL:-$(load_toml_root_var base_url "$HOME/.codex/config.toml" || true)}"
  export OPENAI_BASE_URL
fi

if [[ -z "${HTTP_PROXY:-}" ]]; then
  HTTP_PROXY="$(load_env_var HTTP_PROXY .env || true)"
  export HTTP_PROXY
fi

if [[ -z "${HTTPS_PROXY:-}" ]]; then
  HTTPS_PROXY="$(load_env_var HTTPS_PROXY .env || true)"
  export HTTPS_PROXY
fi

if [[ -z "${ALL_PROXY:-}" ]]; then
  ALL_PROXY="$(load_env_var ALL_PROXY .env || true)"
  export ALL_PROXY
fi

if [[ -z "${NO_PROXY:-}" ]]; then
  NO_PROXY="$(load_env_var NO_PROXY .env || true)"
  export NO_PROXY
fi

IMAGE_API_KEY="${OPENAI_IMAGE_API_KEY:-${OPENAI_API_KEY:-}}"

if [[ -z "${IMAGE_API_KEY:-}" ]]; then
  echo "OPENAI_IMAGE_API_KEY or OPENAI_API_KEY is not set" >&2
  exit 1
fi

IMAGE_PATH="${1:-11客厅-新1.jpg}"
MODEL="${MODEL:-$(load_env_var OPENAI_IMAGE_MODEL .env || true)}"
MODEL="${MODEL:-$(load_codex_project_var image_model || true)}"
MODEL="${MODEL:-$(load_codex_project_var OPENAI_IMAGE_MODEL || true)}"
MODEL="${MODEL:-$(load_toml_root_var image_model || true)}"
MODEL="${MODEL:-$(load_toml_root_var OPENAI_IMAGE_MODEL || true)}"
MODEL="${MODEL:-gpt-image-1.5}"
IMAGE_API_BASE="${OPENAI_BASE_URL:-https://api.openai.com/v1}"
IMAGE_EDIT_URL="${IMAGE_API_BASE%/}/images/edits"
SIZE="${SIZE:-1536x1024}"
QUALITY="${QUALITY:-high}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-png}"

PROMPT="$(cat <<'EOF'
Edit this interior rendering.

Goal:
Change all visible wood-grain cabinetry parts in the image to Cleaf LR65 Poronoce.

Material reference:
Cleaf LR65 Poronoce, a light natural oak finish with fine straight grain, soft warm beige wood tone, subtle realistic timber variation, refined matte panel surface.

Change only these wood-grain areas:
- the wood cabinetry around the coffee station on the left
- the vertical wood slatted panel near the center-left
- the small lower wood cabinet below that slatted panel
- the wood frame, shelves, and lower drawer fronts of the open shelving unit on the right side of the main cabinet wall

Keep unchanged:
- room geometry
- camera angle and perspective
- all white cabinet doors
- marble back panels
- countertop objects and decor
- floor, ceiling, walls, lighting, balcony laundry area
- cabinet proportions, panel gaps, and handle-free detailing

Material constraints:
- use LR65 as a light natural oak with fine straight grain
- keep the wood tone warm beige, not yellow, not orange, not red
- keep a realistic matte finish
- preserve subtle grain direction and realistic wood texture scale
- do not turn the wood into heavy mountain grain or dark walnut
- do not alter any non-wood parts
EOF
)"

curl --fail-with-body -sS "${IMAGE_EDIT_URL}" \
  -H "Authorization: Bearer $IMAGE_API_KEY" \
  -F "model=${MODEL}" \
  -F "image[]=@${IMAGE_PATH}" \
  -F "size=${SIZE}" \
  -F "quality=${QUALITY}" \
  -F "output_format=${OUTPUT_FORMAT}" \
  -F "prompt=${PROMPT}"
