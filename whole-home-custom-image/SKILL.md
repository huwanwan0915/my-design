---
name: "whole-home-custom-image"
description: "用于全屋定制、室内设计、柜体改款、材质替换、软装换搭、空间效果图重绘与局部编辑。适合客厅、餐厅、卧室、书房、厨房、衣帽间、阳台、玄关等空间的效果图修改、风格改造、柜门板替换、配色调整、灯光氛围优化、布局微调和方案出图。需要保留原始空间结构或视角时优先走改图流程，而不是完全重生新图。"
---

# Whole Home Custom Image

用于“全屋定制效果图修改”和“室内空间方案出图”。

如果用户提到具体板材编码、花色名、饰面体系，先读取 `references/board-material-library.md`。如果库里已有条目，优先按库内品牌、编码、材质描述、颜色锚点和使用约束来写提示词，不要凭空改色。

## 何时使用

- 用户要改现有空间图，而不是只写文案
- 用户要调整柜体、门板、台面、背景墙、地板、灯光、软装、配色
- 用户要基于原图保留户型、机位、透视关系、采光方向
- 用户要快速出多个风格版本，用于方案比稿或客户确认

## Key 与模型策略

默认优先从运行时环境变量读取配置；未设置时，再从仓库根目录 `.env` 和 Codex 配置文件回退读取。

- 普通请求读取顺序：环境变量 `OPENAI_API_KEY` -> 仓库 `.env` -> `~/.codex/auth.json` 中的 `OPENAI_API_KEY`
- 图片生成或改图 key 读取顺序：环境变量 `OPENAI_IMAGE_API_KEY` -> 仓库 `.env` -> `~/.codex/auth.json` 中的 `OPENAI_IMAGE_API_KEY` -> 回退到普通 `OPENAI_API_KEY`
- 图片模型读取顺序：环境变量 `OPENAI_IMAGE_MODEL` -> 仓库 `.env` -> `~/.codex/config.toml` 中项目级或根级 `image_model` / `OPENAI_IMAGE_MODEL`
- 如果没有单独配置图片模型，默认回退到 `gpt-image-1.5`

`.env` 建议写法：

```dotenv
OPENAI_API_KEY=your_key_here
OPENAI_IMAGE_API_KEY=your_image_key_here
OPENAI_IMAGE_MODEL=gpt-image-2
```

`~/.codex/auth.json` / `~/.codex/config.toml` 也可这样配：

```json
{
  "OPENAI_API_KEY": "your_default_key_here",
  "OPENAI_IMAGE_API_KEY": "your_image_key_here"
}
```

```toml
image_model = "gpt-image-2"

[projects."/Users/maitao/my-design"]
image_model = "gpt-image-2"
```

如果 `.env` 里用了带 `export` 的 shell 写法，也要兼容读取，但新配置应尽量改成上面的标准 dotenv 形式。

## 生成通道规则

以后默认按下面顺序决定图片生成通道，不要混用概念：

0. 如果是“保留原图结构的室内改图 / 板材替换 / 木纹替换”，默认优先使用会话内置生图工具做 edit，不要先用本地 Swift、CoreGraphics 或手工叠色脚本伪造材质替换结果。
1. 先看 Codex 全局配置是否已经提供了图片专用 key、图片模型和兼容接口地址
   - `~/.codex/auth.json`
   - `~/.codex/config.toml`
2. 如果项目级 `model_provider` 和根级 `model_provider` 同时存在，优先使用根级 `model_provider` 对应的 `base_url`；如果根级没有，再回退到项目级 `model_provider` 对应的 `base_url`
3. 如果 `config.toml` 里配置了 provider `base_url`，图片请求默认优先走该兼容接口，不要硬编码回 `api.openai.com`
4. 只有在本地脚本已经正确读取了 `OPENAI_IMAGE_API_KEY`、`OPENAI_IMAGE_MODEL`、`OPENAI_BASE_URL` 后，才允许走本地脚本出图
5. 如果会话内已有稳定的直接出图路径，优先使用同一条路径连续完成同类任务，不要中途切换到另一条未验证链路

明确区分两件事：

- “配置链路已跑通”指 key、model、base_url 的读取优先级正确
- “图片已成功生成”指接口调用真的返回了图像数据并落盘

不要再把这两件事混为一谈。

额外硬规则：

- 用户明确要求“用内置生图工具改”时，必须使用内置生图工具，不要退回本地脚本。
- 对像 `LR65` 这种需要接近实拍板样的任务，本地 Swift 叠色、简单贴纹或区域染色不能视为合格交付，只能作为临时分析手段，不能冒充最终改图结果。

## 模型策略

这类任务优先级不是“通用绘图”，而是“强指令遵循 + 室内细节编辑 + 参考图一致性”。

- 首选图像模型：`gpt-image-2`
  适合高质量室内改图、材质替换、柜体细节、灯光氛围、软装重搭。
- 稳定兼容版本：`gpt-image-1`
  适合常规方案图和中间稿。
- 快速草图或低成本批量试错：`gpt-image-1-mini`

重要限制：

- 当前 skill 的 `agents/openai.yaml` 没有标准字段可直接锁定图像模型。
- 如果走 Images API 并且你能显式传 `model`，本 skill 默认要求优先使用 `OPENAI_IMAGE_MODEL`，未配置时回退到 `gpt-image-1.5`。
- 如果走 Images API 或 Responses API 的图片工具，默认优先使用 `OPENAI_IMAGE_API_KEY`，未配置时回退到 `OPENAI_API_KEY`。
- 如果走 Responses API，生成设计图时也优先直接使用 GPT 生图模型，而不是默认落到通用文本模型。
- 在 Responses API 里，图像编辑优先设为 `action: edit`。

执行时按下面规则处理：

1. 能显式指定图像模型时，默认用 `OPENAI_IMAGE_MODEL`；未配置时用 `gpt-image-1.5`。
2. 做“保留原图结构的室内改图”时，优先走 edit 流程，而不是 generate。
3. 如果用户强调稳定兼容而不是最新效果，降到 `gpt-image-1`。
4. 如果用户强调低成本多方案，再降到 `gpt-image-1-mini`。

## 工作流

1. 先判断是“改图”还是“新生成”。
2. 先逐字核对原图文件路径和文件名。用户给的是绝对路径时，直接以该路径为准，不要口头猜测或擅自替换成近似文件名。
3. 只要用户希望保留原空间结构、机位、采光、柜体比例，就按“改图”处理。
4. 如果是这类“保留原图结构的板材替换”，默认优先使用会话内置生图工具做 edit，并先把原图与板材实拍都加载到会话里作为可见输入。
5. 如果用户提供了板材实拍/样板图，生图前必须先从实拍图提取色块，形成颜色锚点，再写提示词或调用生图；不要跳过取色直接凭文字描述出图。
6. 如果当前会话无法直接调用内置生图工具，但本地脚本可读取 `OPENAI_BASE_URL` 并成功返回图像数据，则允许走本地 `curl` / `Responses API` 链路生成最终图，不要再回退到未验证的脚本或手工兜底。
7. 不要把本地 Swift、CoreGraphics 叠色或简单贴纹脚本当作最终改图交付；这类脚本最多用于临时分析区域，不用于最终成图。
8. 优先锁定不允许变化的内容：
   - 墙体结构
   - 门窗位置
   - 相机机位和透视
   - 地面铺贴方向
   - 吊顶关系
   - 已确认的柜体尺寸关系
9. 再定义允许变化的内容：
   - 柜门造型
   - 材质和纹理
   - 颜色
   - 拉手和五金
   - 背景墙
   - 灯带、主灯、氛围光
   - 软装和摆件
10. 输出时默认给 1 个主版本 + 2 个轻微变化版本，除非用户明确只要单版。

## 板样优先规则

如果用户提供了板材实拍、局部近照、手机拍摄样板或供应商截图，优先级高于文字描述和库内近似色锚点。

- 实拍板样优先作为材质参考，不要只复述库内 `prompt_anchor`
- 生图前先从实拍图中避开文字、水印、强高光、重阴影区域取色块；至少记录高光、基底、纹理线、深纹/阴影等 3–5 个近似色锚点
- 色块只用于 AI 视觉还原和提示词约束，不当作生产打样色值；如果环境无法取色，要明确说明“未能取色”，不能假装已经提取
- 提示词里要把取色结果转写成颜色方向，例如“来自实拍色块的暖棕灰基底、深棕细纹、低光高光”，而不是只写抽象形容词
- 先从实拍中提炼 4 个关键维度：底色、冷暖、纹路方向、纹路对比度
- 如果实拍和库内锚点不完全一致，优先贴近实拍视觉，但不要偏离主编码所属的材质家族
- 有实拍时，提示词里要明确写“以该板样为唯一材质基准”或同等约束
- 对木纹板尤其要补写反例约束：不要偏黄、不要偏红、不要偏灰白、不要大山纹、不要过强对比
- 对 `Cleaf LR65` 必须额外加硬约束：实拍板样是唯一参照，禁止退化成 generic light oak，禁止把纹路做粗、做花、做红、做黄、做粉，禁止把哑面板材做成天然原木感过强的效果。
- 生成前要把 LR65 的底色、纹路密度、纹路方向、对比度写成明确约束；生成后要立刻和实拍板样对照检查，若颜色或纹路不贴，就继续收敛，不把偏差版当最终版。

对于像 `Cleaf LR65` 这类浅暖木纹板，实拍校正通常比编码本身更重要，因为模型很容易退化成“泛浅橡木”。

## 多轮收敛经验

当用户对“像不像某个板材”不满意时，不要只反复重说同一段 prompt，应该按下面顺序收敛：

1. 先判断偏差类型：
   - 颜色偏浅或偏深
   - 色温偏黄、偏红、偏灰、偏粉
   - 纹路过粗、过弱、过花、过均匀
   - 整体太像天然木，不像板材饰面
2. 然后只改最关键的 1 到 2 个维度，不要一次性改满所有形容词
3. 每一轮都保留上一版成品，但只把最终确认版放进仓库
4. 如果已经有实拍板样，后续轮次要明确写“以实拍为唯一参考，不参考上一轮生成图的错误色调”

实操上，木纹材质最常见的失败是：

- 生成成 generic light oak
- 颜色漂白或偏粉
- 纹理做成大山纹或 rustic knot
- 过度追求木感，反而不像定制板材
- `Cleaf LR65` 还常见一个额外失败：在远看上“像浅木”，但近看底色偏黄、纹路偏粗、板感不够，这种不能算成功。

这时要把 prompt 收紧成“板材实拍驱动”，而不是继续泛写“natural oak”。

## 产物管理

改图流程很容易产生大量中间版本。默认规则：

- 原始图保留
- 最终交付图保留
- `_prev`、`_backup`、`_tweak`、`_v2`、`_v3` 这类中间试错图默认不提交
- 如果仓库需要留痕，优先保留最终版和少量关键对比版，不要把整个迭代链都提交
- 应配合 `.gitignore` 屏蔽中间产物，避免工作区长期变脏

## 本地出图链路

当会话内没有可直接调用的内置生图入口时，优先使用仓库内已经跑通的本地脚本链路：

1. 用 `lr65-image-edit-curl.sh` 走 `curl` 请求 `images.edits`
2. 如果 `OPENAI_BASE_URL` 未显式设置，按 `~/.codex/config.toml` 的根级 `model_provider` 读取 `base_url`
3. 若根级没有，再回退到项目级 `model_provider`
4. 只有当 `base_url`、`OPENAI_IMAGE_API_KEY`、`OPENAI_IMAGE_MODEL` 都可读时，才执行本地出图
5. 生成后把返回的 `b64_json` 落盘为工作区图片，再做最终交付

## 室内改图约束

做全屋定制改图时，优先保证这些约束：

- 不要随意改户型
- 不要改变视角高度和广角关系
- 不要把柜体做到不合理的厚度
- 不要让柜门缝、踢脚线、收口、台面转角失真
- 不要让灯光方向互相冲突
- 不要让木纹、石纹、岩板纹理出现明显重复或尺度错误
- 不要为了“更好看”私自增加大件家具
- 不要让空间动线被新增物体堵住

如果用户没有特别说明，默认保留：

- 空间骨架
- 原始构图
- 已有主要家具位置
- 门窗
- 天花和地面大关系

## 默认输出参数建议

- 客厅、餐厅、卧室、书房横向空间图：`1536x1024`
- 通高柜、玄关柜、衣柜立面强调图：`1024x1536`
- 中间方案比稿：`quality: medium`
- 客户终稿汇报：`quality: high`

## 提示词结构

每次都把需求整理成下面格式，再发给绘图模型：

```text
Task: interior image edit
Room type: <客厅/餐厅/卧室/厨房/衣帽间/玄关/阳台/书房>
Goal: <本次要改什么>
Keep unchanged: <必须不变的内容>
Change list: <允许变化的内容>
Style: <奶油/现代极简/原木/轻奢/中古/法式/意式等>
Cabinet system: <电视柜/餐边柜/玄关柜/衣柜/书柜/橱柜/阳台柜>
Materials: <门板、台面、墙面、地面、金属、玻璃>
Color direction: <主色、副色、点缀色>
Lighting: <自然光/主灯/灯带/氛围灯要求>
Composition: keep original camera angle and perspective
Constraints: preserve room geometry, door/window positions, realistic scale, clean joinery details
Avoid: warped cabinet proportions, fake shadows, repeated textures, extra furniture, changed layout
```

## 常用改图模板

### 柜体换款

```text
Edit this interior image. Keep the room geometry, camera angle, floor, ceiling, and window positions unchanged.
Only redesign the cabinet system.
Replace the cabinet doors with <style>, update handles to <type>, refine joinery lines, and keep realistic panel gaps.
Maintain accurate cabinet depth, countertop thickness, and lighting direction.
Do not add or remove major furniture.
```

### 材质换色

```text
Edit this interior image. Keep the layout and perspective unchanged.
Only change materials and colors.
Update cabinet finish to <material/color>, wall finish to <material/color>, and floor to <material/color>.
Keep texture scale realistic and consistent across panels.
Do not alter the room structure or furniture positions.
```

### 软装调风格

```text
Edit this interior image into a <style> whole-home custom interior.
Keep the architecture, cabinetry layout, and camera angle unchanged.
Adjust soft furnishings, decor, textiles, artwork, and lighting mood only.
Preserve realistic circulation and avoid overcrowding.
```

## 缺信息时的补问顺序

只在缺关键输入时追问，优先级如下：

1. 是改原图还是出新图
2. 哪些内容必须保留不变
3. 想改哪些柜体或空间
4. 目标风格
5. 主材和颜色方向
6. 是中间稿还是终稿

如果以上信息大部分已经给出，直接开始，不要过度追问。
