# Image Generation Workflow

This project uses the local Codex image-generation launcher instead of storing API keys in the repository.

## Required local setup

Each computer must have these files outside Git:

- `~/.codex/bin/imagegen-cli` — executable launcher
- `~/.codex/imagegen.env` — contains `OPENAI_API_KEY` and `CODEX_IMAGEGEN_MODEL`
- `~/.codex/config.toml` — contains the provider `base_url`, for example `https://.../v1`

Do not commit API keys or `~/.codex/imagegen.env`.

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
- reads `OPENAI_BASE_URL` from the environment when set
- otherwise reads the first `base_url` from `~/.codex/config.toml`
- keeps the API key outside this repository

## Operational lessons

- If direct `api.openai.com` calls time out, use the `base_url` from `~/.codex/config.toml`.
- If `imagegen-cli` appears to hang after 60–90 seconds, first check whether the target output file already exists; the image may have been written even if the CLI has not returned final logs.
- Save final image assets under `output/imagegen/` unless a task needs another explicit path.
- Do not overwrite originals unless explicitly requested.
