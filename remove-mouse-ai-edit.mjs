import fs from "fs";
import OpenAI from "openai";

function readEnvValue(key, envPath = ".env") {
  if (!fs.existsSync(envPath)) return undefined;
  const lines = fs.readFileSync(envPath, "utf8").split(/\r?\n/);
  for (let i = lines.length - 1; i >= 0; i -= 1) {
    const line = lines[i].trim();
    if (!line || line.startsWith("#")) continue;
    const match = line.match(new RegExp(`^(?:export\\s+)?${key}\\s*=\\s*(.*)$`));
    if (!match) continue;
    let value = match[1].trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    return value;
  }
  return undefined;
}

const apiKey = process.env.OPENAI_IMAGE_API_KEY || process.env.OPENAI_API_KEY || readEnvValue("OPENAI_IMAGE_API_KEY") || readEnvValue("OPENAI_API_KEY");
const baseURL = process.env.OPENAI_BASE_URL || readEnvValue("OPENAI_BASE_URL");
const model = process.env.OPENAI_IMAGE_MODEL || readEnvValue("OPENAI_IMAGE_MODEL") || "gpt-image-1";

if (!apiKey) throw new Error("OPENAI_IMAGE_API_KEY or OPENAI_API_KEY is not set");

const client = new OpenAI({ apiKey, baseURL });
const imagePath = process.argv[2] || "11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png";
const imageBase64 = fs.readFileSync(imagePath, "base64");

const prompt = `Use case: precise-object-edit
Asset type: interior rendering revision
Primary request: remove only the small metallic mouse figurine standing on the black coffee table in front of the right-side bookshelf, then naturally reconstruct the hidden background and tabletop.
Input images: Image 1: edit target.
Scene/backdrop: modern living room render with white cabinet wall, wood open shelf, black coffee table, marble table base, bright laundry area on the right.
Subject: interior rendering.
Style/medium: photorealistic architectural interior rendering.
Composition/framing: keep the exact same camera angle, framing, perspective, and crop.
Lighting/mood: keep the current soft neutral daylight and existing shadows.
Materials/textures: preserve the original wood grain, marble texture, black tabletop material, floor reflections, wall tones, and shelf details.
Constraints: remove only the mouse figurine; keep all other furniture, decor, cabinetry, shelf objects, toy figure on the marble table, laundry area, and room geometry unchanged; reconstruct the bookshelf drawer fronts and black tabletop behind the removed figurine naturally; preserve realistic occlusion, edges, and reflections.
Avoid: do not move objects, do not change cabinet layout, do not alter colors globally, do not blur the bookshelf, do not add new decor, do not repaint the room, no watermark.`;

const response = await client.responses.create({
  model,
  input: [
    {
      role: "user",
      content: [
        { type: "input_text", text: prompt },
        { type: "input_image", image_url: `data:image/png;base64,${imageBase64}` },
      ],
    },
  ],
  tools: [
    {
      type: "image_generation",
      action: "edit",
      size: "1536x1024",
      quality: "high",
      format: "png",
    },
  ],
  tool_choice: { type: "image_generation" },
});

const image = response.output.find((item) => item.type === "image_generation_call");
if (!image?.result) throw new Error("Image generation did not return image data");

const outputPath = "11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1.png";
fs.writeFileSync(outputPath, Buffer.from(image.result, "base64"));
console.log(outputPath);
