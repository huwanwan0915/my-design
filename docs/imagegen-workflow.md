# Image Generation Workflow

This project uses the local Codex image-generation launcher instead of storing API keys in the repository.

## Required local setup

Each computer must have these files outside Git:

- `~/.codex/bin/imagegen-cli` — executable launcher
- `~/.codex/imagegen.env` — contains `CODEX_IMAGEGEN_MODEL`, and may also export `OPENAI_API_KEY`
- `~/.codex/config.toml` — contains the selected `model_provider` and provider `base_url`
- `~/.codex/auth.json` — may also provide `OPENAI_API_KEY`

Do not commit API keys or any `~/.codex/*` auth/config files.

## Portable project command

Run image generation through the project wrapper:

```bash
./scripts/imagegen-cli-local.sh edit \
  --image input.png \
  --mask mask.png \
  --prompt-file prompt.txt \
  --size 1536x1024 \
  --quality high \
  --input-fidelity high \
  --out output/imagegen/result.png
```

The wrapper:

- uses `~/.codex/bin/imagegen-cli`
- relies on the local Codex launcher and your `~/.codex/*` config files
- reads `CODEX_IMAGEGEN_MODEL` from `~/.codex/imagegen.env`
- uses the provider `base_url` configured in `~/.codex/config.toml`
- allows auth to come from `~/.codex/imagegen.env` or `~/.codex/auth.json`
- lets the launcher pass `CODEX_IMAGEGEN_MODEL` through to `image_gen.py`
- keeps the API key outside this repository

## Operational lessons

- If image requests should go through a proxy or compatible endpoint, set the provider `base_url` in `~/.codex/config.toml`.
- If both `~/.codex/imagegen.env` and `~/.codex/auth.json` contain `OPENAI_API_KEY`, keep them aligned to avoid debugging the wrong credential path.
- If `imagegen-cli` appears to hang after 60–90 seconds, first check whether the target output file already exists; the image may have been written even if the CLI has not returned final logs.
- Save final image assets under `output/imagegen/` unless a task needs another explicit path.
- Do not overwrite originals unless explicitly requested.
