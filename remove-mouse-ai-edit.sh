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

OPENAI_API_KEY="${OPENAI_API_KEY:-$(load_env_var OPENAI_API_KEY .env || true)}"
OPENAI_BASE_URL="${OPENAI_BASE_URL:-$(load_env_var OPENAI_BASE_URL .env || true)}"
IMAGE_API_KEY="${OPENAI_IMAGE_API_KEY:-${OPENAI_API_KEY:-}}"
MODEL="${OPENAI_IMAGE_MODEL:-gpt-image-1}"
IMAGE_PATH="${1:-11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png}"
OUTPUT_PATH="${2:-11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1.png}"
IMAGE_API_BASE="${OPENAI_BASE_URL:-https://api.openai.com/v1}"
IMAGE_EDIT_URL="${IMAGE_API_BASE%/}/images/edits"

[[ -n "${IMAGE_API_KEY:-}" ]] || { echo "OPENAI API key not set" >&2; exit 1; }

PROMPT="$(cat <<'PROMPT'
Edit this interior rendering.

Goal:
Remove only the small metallic mouse figurine standing on the black coffee table in front of the right-side bookshelf.

Keep unchanged:
- room geometry
- camera angle and perspective
- lighting, reflections, and shadows
- all cabinetry and drawer layout
- all shelf objects and decor
- the black toy figure on the marble table in the foreground
- marble textures, walls, floor, ceiling, laundry area, and all other furniture

Requirements:
- reconstruct the hidden black tabletop naturally where the mouse figurine was standing
- reconstruct the hidden bookshelf drawer fronts and seams behind the figurine naturally
- preserve the original wood grain, panel gaps, and drawer proportions
- preserve realistic occlusion and edge quality
- keep the result photorealistic and seamless

Do not:
- move any objects
- change any colors globally
- change the bookshelf design
- blur the image
- add new objects
- alter any other part of the room
PROMPT
)"

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

curl --fail-with-body -sS "$IMAGE_EDIT_URL" \
  -H "Authorization: Bearer $IMAGE_API_KEY" \
  -F "model=${MODEL}" \
  -F "image[]=@${IMAGE_PATH}" \
  -F "size=1536x1024" \
  -F "quality=high" \
  -F "output_format=png" \
  -F "prompt=${PROMPT}" > "$TMP_JSON"

python3 - "$TMP_JSON" "$OUTPUT_PATH" <<'PY'
import base64
import json
import sys

jpath, opath = sys.argv[1], sys.argv[2]
with open(jpath, "r", encoding="utf-8") as f:
    data = json.load(f)

images = data.get("data") or []
if not images:
    raise SystemExit("No image data returned")

b64 = images[0].get("b64_json")
if not b64:
    raise SystemExit("No b64_json in response")

with open(opath, "wb") as f:
    f.write(base64.b64decode(b64))

print(opath)
PY
