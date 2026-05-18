#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY is not set" >&2
  exit 1
fi

IMAGE_PATH="${1:-11客厅-新1.jpg}"
MODEL="${MODEL:-gpt-image-2}"
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

curl -s https://api.openai.com/v1/images/edits \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "model=${MODEL}" \
  -F "image[]=@${IMAGE_PATH}" \
  -F "size=${SIZE}" \
  -F "quality=${QUALITY}" \
  -F "output_format=${OUTPUT_FORMAT}" \
  -F "prompt=${PROMPT}"

