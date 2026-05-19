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
OPENAI_IMAGE_MODEL=gpt-image-2-3x2-4k
```

`~/.codex/auth.json` / `~/.codex/config.toml` 也可这样配：

```json
{
  "OPENAI_API_KEY": "your_default_key_here",
  "OPENAI_IMAGE_API_KEY": "your_image_key_here"
}
```

```toml
image_model = "gpt-image-2-3x2-4k"

[projects."/Users/maitao/my-design"]
image_model = "gpt-image-2-3x2-4k"
```

如果 `.env` 里用了带 `export` 的 shell 写法，也要兼容读取，但新配置应尽量改成上面的标准 dotenv 形式。

## 模型策略

这类任务优先级不是“通用绘图”，而是“强指令遵循 + 室内细节编辑 + 参考图一致性”。

- 首选图像模型：`gpt-image-2-3x2-4k`
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
2. 只要用户希望保留原空间结构、机位、采光、柜体比例，就按“改图”处理。
3. 优先锁定不允许变化的内容：
   - 墙体结构
   - 门窗位置
   - 相机机位和透视
   - 地面铺贴方向
   - 吊顶关系
   - 已确认的柜体尺寸关系
4. 再定义允许变化的内容：
   - 柜门造型
   - 材质和纹理
   - 颜色
   - 拉手和五金
   - 背景墙
   - 灯带、主灯、氛围光
   - 软装和摆件
5. 输出时默认给 1 个主版本 + 2 个轻微变化版本，除非用户明确只要单版。

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
