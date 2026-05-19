# Model Notes

用于记录这个 skill 的模型偏好，避免后续维护时误把“主对话模型”和“图像生成模型”混为一谈。

## 推荐

- Key 选择：
  - 普通请求读取顺序：环境变量 `OPENAI_API_KEY` -> 仓库 `.env` -> `~/.codex/auth.json`
  - 图片生成或改图优先使用 `OPENAI_IMAGE_API_KEY`
  - 未配置 `OPENAI_IMAGE_API_KEY` 时回退到普通 `OPENAI_API_KEY`

- 直接走 Images API：
  - 首选 `gpt-image-2-3x2-4k`
  - 稳定兼容可用 `gpt-image-1`
  - 快速草图可用 `gpt-image-1-mini`

- 走 Responses API / `image_generation` 工具：
  - 可直接使用 `OPENAI_IMAGE_MODEL`
  - 未配置时，额外回退读取 `~/.codex/config.toml` 的 `image_model` 或 `OPENAI_IMAGE_MODEL`
  - 也可用当前可用的 GPT-5 系列主模型先整理指令，再调用图像工具
  - 对于全屋定制改图，优先使用编辑语义而不是纯生成语义

## 原因

- 全屋定制改图依赖局部编辑、材质稳定性、结构保留和细节遵循。
- 这类任务比“纯创意出图”更需要严格执行保留项和修改项。
- 因此默认优先更强的图像编辑模型，而不是只追求低成本。
