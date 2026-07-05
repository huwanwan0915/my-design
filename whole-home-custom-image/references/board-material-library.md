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

### Cleaf LS72

- `brand`: `Cleaf` / `可丽芙`
- `code`: `LS72`
- `aliases`: none
- `series_or_finish`: `LS wood finish`
- `visual_family`: `light warm beige honey-oak board`, `pale natural oak`, `fine soft straight vertical grain`
- `base_colors`:
  - `#D9BF98` soft highlight
  - `#C9A97C` base
  - `#B99363` fine grain
  - `#9F7B50` deep grain
- `surface_notes`: 当前确认版应理解为浅暖米色、浅蜂蜜橡木感的可丽芙木纹板。整体比 LR65 更浅、更干净、更柔和，黄调存在但不能过度发黄或发红；底色是温润浅木色，不是灰白橡木、不是漂白木，也不是深驼棕。纹理以竖向细直纹为主，线条柔和、连续、低对比，局部有很轻的天然木纹流动感，但不能出现粗大山纹、强烈结疤、斑驳旧木或乡村原木感。表面是现代定制板的 satin-matte/soft-sheen 观感，反光柔和，不能做成高光亮面或死哑平涂。
- `prompt_anchor`: `Cleaf LS72, a light warm beige honey-oak board finish with a clean pale natural oak base, fine soft straight vertical grain, low-contrast warm golden-beige variation, and a refined satin-matte soft-sheen panel surface, lighter and cleaner than LR65, never gray-washed, bleached white, red, dark camel-brown, knotty, rustic, or high-gloss`
- `confidence`: `high`
- `source_note`: 按用户提供的两张 LS72 参考图入库。图面可见 `LS72` 标识，第一张为近距离板样，第二张为大面积墙板/层板应用场景。核心记忆点是：浅暖蜂蜜米橡、细直低对比竖纹、现代柔哑光板材，比 LR65 更浅更清爽。

### Cleaf S185

- `brand`: `Cleaf` / `可丽芙`
- `code`: `S185`
- `aliases`: `S/85`, `S185 QUERCIA`, `QUERCIA / QUERCIA A`
- `series_or_finish`: `QUERCIA`
- `visual_family`: `medium warm smoked oak`, `brown taupe oak`, `fine dense vertical oak grain`
- `base_colors`:
  - `#B08B67` warm highlight
  - `#8E6B4F` base
  - `#6F513D` fine grain
  - `#4B352B` deep shadow grain
- `surface_notes`: 当前确认版应理解为中深暖棕橡木/烟熏橡木板材，底色是带灰褐感的温暖棕色，不是浅橡木、不是黄橡木，也不是红木。整体比 LS72 深很多，比 LR65 更稳重、更烟熏、更偏棕灰；纹理是非常细密的竖向橡木直纹，线条连续、密集、低到中等对比，带轻微木纤维拉丝感和自然深浅带，但不能做成粗山纹、大结疤、斑驳旧木或黑胡桃。表面是高级定制板的 satin-matte/soft-sheen 低光观感，触感应像细腻木皮/同步纹板，不能高光、油亮或塑料感。
- `prompt_anchor`: `Cleaf S185 Quercia, a medium warm smoked-oak board finish with a brown-taupe oak base, fine dense straight vertical oak grain, subtle fiber-like linear texture, low-to-medium contrast warm dark grain variation, and a refined satin-matte soft-sheen panel surface, deeper and smokier than LR65 and much darker than LS72, never pale oak, yellow oak, red wood, black walnut, rustic knotty timber, mountain grain, or high-gloss`
- `confidence`: `high`
- `source_note`: 按用户提供的两张 S185/QUERCIA 参考图入库。图面可见 `S/85`、`S185 QUERCIA / QUERCIA A` 标识，应用在高柜/墙板大面积板面。核心记忆点是：中深暖棕烟熏橡木、细密竖向直纹、棕灰木纤维质感、低光柔哑面。

### Cleaf LS53

- `brand`: `Cleaf` / `可丽芙`
- `code`: `LS53`
- `aliases`: `PORO NOCE`, `Poro Noce LS53`
- `series_or_finish`: `PORO NOCE`
- `visual_family`: `dark smoked noce`, `deep brown walnut board`, `high-contrast vertical walnut-like grain`
- `base_colors`:
  - `#6B4C3C` soft highlight / warm amber grain
  - `#604538` amber grain
  - `#503C33` deep brown base
  - `#4C392F` base shadow
  - `#3F302B` deep shadow grain
- `surface_notes`: 当前确认版应理解为深色烟熏 Noce/胡桃感的可丽芙木纹板。底色是深棕到黑棕，不是浅橡木、黄橡木或灰橡木；纹理夹红棕、焦糖棕、琥珀棕竖向长纹，深浅带比 S185、LR65、LS72 都更强、更戏剧化。纹路方向以竖向连续长纹为主，允许中高对比的细密与局部宽纹交织，但不能做成粗糙旧木、乡村结疤、黑到无层次的纯黑胡桃、过红的红木、油亮高光或塑料贴皮。表面仍是高级定制板的 satin-matte/soft-sheen 低光板材质感。
- `prompt_anchor`: `Cleaf LS53 Poro Noce, a dark smoked noce walnut board finish with a deep brown to black-brown base, warm reddish-brown caramel and amber vertical grain streaks, medium-to-high contrast long straight wood grain, refined satin-matte soft-sheen panel surface, darker and more dramatic than S185, never pale oak, yellow oak, gray oak, flat black walnut, red mahogany, rustic knotty timber, coarse mountain grain, oily gloss, or plastic laminate`
- `confidence`: `high`
- `source_note`: 按用户提供的 LS53 实拍板样入库；本地参考图为 `可丽芙ls53.jpg`，图面左下可见 `PORO NOCE LS53`。取色避开文字与边缘区域，视觉锚点为深棕/黑棕基底、红棕与琥珀焦糖竖纹、中高对比深色胡桃/Noce 质感。色值仅用于 AI 视觉还原，不作为生产打样色值。

## Prompt Usage

当用户指定库内板材时，把该条目的 `prompt_anchor` 直接拼进改图提示词，并补上结构保留约束，例如：

```text
Use the cabinetry finish from the board-material library:
Cleaf B072 Fiocco, a soft warm light greige board finish with subtle plain texture, low-sheen matte reflection, clean and understated Italian panel look.
Keep cabinet proportions, panel gaps, handle positions, and room geometry unchanged.
```
