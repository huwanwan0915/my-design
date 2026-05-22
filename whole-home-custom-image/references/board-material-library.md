# Board Material Library

用于沉淀全屋定制常用板材色号、品牌、花色别名、视觉锚点和绘图约束。

## 字段规则

- `brand`: 品牌
- `code`: 主编码
- `aliases`: 别名或常见误写
- `series_or_finish`: 系列、纹理或表面名
- `visual_family`: 视觉归类
- `base_colors`: 近似颜色锚点，仅用于提示词，不替代官方色卡
- `surface_notes`: 表面和反光特征
- `prompt_anchor`: 出图时可直接复用的英文锚点
- `confidence`: `high` / `medium` / `low`
- `source_note`: 来源说明

重要规则：

- 色值默认是“视觉近似值”，只用于 AI 改图提示，不当作生产打样色值。
- 如果图片拍摄光线明显偏暖或偏冷，应保留多个近似色锚点。
- 如果用户提供了实拍板样，优先记录“实拍视觉”而不是凭空补全。

## Entries

### Cleaf B072

- `brand`: `Cleaf` / `可丽芙`
- `code`: `B072`
- `aliases`: `B072 FIOCCO`, `FB072 (historical user note)`
- `series_or_finish`: `FIOCCO`
- `visual_family`: `warm light greige`, `soft warm gray`, `plain matte`
- `base_colors`:
  - `#D9D5CF` high-light
  - `#CAC5BE` base
  - `#B9B3AC` mid shadow
  - `#A39D97` deep shadow
- `surface_notes`: 表面偏细腻平纹，整体低饱和暖灰米色，反光柔和，不是高亮烤漆，不应出现强镜面高光。
- `prompt_anchor`: `Cleaf B072 Fiocco, a soft warm light greige board finish with subtle plain texture, low-sheen matte reflection, clean and understated Italian panel look`
- `confidence`: `medium`
- `source_note`: 用户确认以板材实物型号为准，主编码使用 `B072`。图面水印可见 `B072`；`FB072` 仅保留为历史备注，避免后续误用。

### Cleaf FB08

- `brand`: `Cleaf` / `可丽芙`
- `code`: `FB08`
- `aliases`: `FB086 (user message, pending reconfirmation)`
- `series_or_finish`: `REFLEX`
- `visual_family`: `charcoal gray`, `dark graphite`, `linear textured matte`
- `base_colors`:
  - `#666867` high-light
  - `#505253` base
  - `#3D3F41` mid shadow
  - `#2A2B2E` deep shadow
- `surface_notes`: 深灰偏石墨色，带细密纵向拉丝/织物感线性质感，整体低光哑面，明暗变化主要来自纹理方向，不应做成纯平无纹深灰板。
- `prompt_anchor`: `Cleaf FB08 Reflex, a dark graphite charcoal board finish with subtle vertical linear texture, refined low-sheen matte reflection, premium Italian panel surface`
- `confidence`: `medium`
- `source_note`: 按板材实物型号入库。图片覆盖字和底部标签均可见 `FB08`、`REFLEX`；用户消息写为 `FB086`，暂记为待复核备注，不作为主编码。

### Cleaf LR65

- `brand`: `Cleaf` / `可丽芙`
- `code`: `LR65`
- `aliases`: none
- `series_or_finish`: `PORONOCE`
- `visual_family`: `warm camel-brown beige board`, `grounded light brown-beige wood`, `extremely fine dense straight vertical grain`
- `base_colors`:
  - `#D7BEA4` soft highlight
  - `#C6A98D` base
  - `#B29173` grain
  - `#947659` deep grain
- `surface_notes`: 当前确认版应理解为偏暖、略深、略棕的驼棕米色板材，不发灰、不发粉、不漂白。纹路是极细密的直纹，方向稳定、连续、低对比，不能做成粗线、花纹或天然木大山纹。表面不是死哑光，而是带轻微板材光泽的 satin-matte 观感，整体要像高端定制板，而不是泛浅橡木。
- `prompt_anchor`: `Cleaf LR65 Poronoce, a distinctly warm camel-brown beige board finish with a grounded light brown-beige base, extremely fine dense straight vertical grain, low-contrast variation, and a soft satin-matte panel surface with a subtle board sheen, never bleached, grayish, pink, or generic pale oak`
- `confidence`: `medium`
- `source_note`: 按板材实物标签与用户确认过的实拍校正。最终记忆点是：比常见浅橡木更暖、更深、更棕，纹路更细更密，并带一点板材光泽。

## Prompt Usage

当用户指定库内板材时，把该条目的 `prompt_anchor` 直接拼进改图提示词，并补上结构保留约束，例如：

```text
Use the cabinetry finish from the board-material library:
Cleaf B072 Fiocco, a soft warm light greige board finish with subtle plain texture, low-sheen matte reflection, clean and understated Italian panel look.
Keep cabinet proportions, panel gaps, handle positions, and room geometry unchanged.
```
