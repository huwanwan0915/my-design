import fs from "fs";
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

if (!process.env.OPENAI_API_KEY) {
  throw new Error("OPENAI_API_KEY is not set");
}

const imagePath = process.argv[2] || "11客厅-新1.jpg";
const imageBase64 = fs.readFileSync(imagePath, "base64");

const firstPrompt = `Edit this interior rendering.

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
- do not alter any non-wood parts`;

const refinePrompt = `Refine the current edited image.

Adjustments:
- make the LR65 wood tone slightly lighter and more neutral warm beige
- reduce any yellow, orange, or reddish cast
- refine the wood grain so it stays fine, straight, and subtle
- keep the matte finish soft and realistic

Do not change:
- any white cabinet surfaces
- any marble surfaces
- any decor objects
- room geometry, perspective, lighting, and layout

The result should read as premium Cleaf LR65 Poronoce cabinetry, with consistent natural oak texture across all edited wood areas.`;

const first = await client.responses.create({
  model: "gpt-5",
  input: [
    {
      role: "user",
      content: [
        {
          type: "input_text",
          text: firstPrompt,
        },
        {
          type: "input_image",
          image_url: `data:image/jpeg;base64,${imageBase64}`,
        },
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

const firstImage = first.output.find(
  (item) => item.type === "image_generation_call",
);

if (!firstImage?.result) {
  throw new Error("First image generation did not return image data");
}

fs.writeFileSync("lr65-first-pass.png", Buffer.from(firstImage.result, "base64"));

const second = await client.responses.create({
  model: "gpt-5",
  previous_response_id: first.id,
  input: refinePrompt,
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

const secondImage = second.output.find(
  (item) => item.type === "image_generation_call",
);

if (!secondImage?.result) {
  throw new Error("Second image generation did not return image data");
}

fs.writeFileSync("lr65-refined.png", Buffer.from(secondImage.result, "base64"));

console.log("Saved lr65-first-pass.png and lr65-refined.png");
