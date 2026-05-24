import AppKit

let basePath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_AI_gpt-image-2-3x2-4k_v1.png"
let aiPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_只去第三层板和摆件_AI_v1.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_只去第三层板和摆件_AI_v2_局部合成.png"

guard let baseImage = NSImage(contentsOfFile: basePath),
      let baseTiff = baseImage.tiffRepresentation,
      let base = NSBitmapImageRep(data: baseTiff),
      let aiImage = NSImage(contentsOfFile: aiPath),
      let aiTiff = aiImage.tiffRepresentation,
      let ai = NSBitmapImageRep(data: aiTiff),
      let result = base.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load images")
}

let width = min(base.pixelsWide, ai.pixelsWide)
let height = min(base.pixelsHigh, ai.pixelsHigh)

func clamp(_ v: CGFloat) -> CGFloat { max(0, min(1, v)) }
func smoothstep(_ edge0: CGFloat, _ edge1: CGFloat, _ x: CGFloat) -> CGFloat {
    let t = clamp((x - edge0) / (edge1 - edge0))
    return t * t * (3 - 2 * t)
}
func ellipse(_ x: CGFloat, _ y: CGFloat, cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, soft: CGFloat) -> CGFloat {
    let d = sqrt(pow((x - cx) / rx, 2) + pow((y - cy) / ry, 2))
    if d <= 1 - soft { return 1 }
    if d >= 1 { return 0 }
    return (1 - d) / soft
}
func rect(_ x: CGFloat, _ y: CGFloat, x0: CGFloat, y0: CGFloat, x1: CGFloat, y1: CGFloat, feather: CGFloat) -> CGFloat {
    let left = smoothstep(x0, x0 + feather, x)
    let right = 1 - smoothstep(x1 - feather, x1, x)
    let top = smoothstep(y0, y0 + feather, y)
    let bottom = 1 - smoothstep(y1 - feather, y1, y)
    return max(0, min(1, min(min(left, right), min(top, bottom))))
}
func capsule(_ x: CGFloat, _ y: CGFloat, x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, r: CGFloat, soft: CGFloat) -> CGFloat {
    let vx = x2 - x1, vy = y2 - y1
    let wx = x - x1, wy = y - y1
    let t = clamp((wx * vx + wy * vy) / (vx * vx + vy * vy))
    let px = x1 + t * vx, py = y1 + t * vy
    let d = sqrt(pow(x - px, 2) + pow(y - py, 2)) / r
    if d <= 1 - soft { return 1 }
    if d >= 1 { return 0 }
    return (1 - d) / soft
}
func maskAt(x: CGFloat, y: CGFloat) -> CGFloat {
    var m: CGFloat = 0
    // Third shelf board only: the board directly underneath the swan decor.
    m = max(m, rect(x, y, x0: 810, y0: 385, x1: 1032, y1: 420, feather: 5))
    // Swan decor and its black curved stand sitting on that board.
    m = max(m, ellipse(x, y, cx: 910, cy: 350, rx: 76, ry: 42, soft: 0.20))
    m = max(m, ellipse(x, y, cx: 965, cy: 352, rx: 58, ry: 38, soft: 0.20))
    m = max(m, capsule(x, y, x1: 840, y1: 352, x2: 1015, y2: 352, r: 9, soft: 0.30))
    m = max(m, capsule(x, y, x1: 842, y1: 348, x2: 875, y2: 372, r: 8, soft: 0.30))
    m = max(m, capsule(x, y, x1: 1015, y1: 348, x2: 984, y2: 372, r: 8, soft: 0.30))
    m = max(m, capsule(x, y, x1: 925, y1: 318, x2: 915, y2: 350, r: 9, soft: 0.30))
    m = max(m, capsule(x, y, x1: 970, y1: 327, x2: 955, y2: 354, r: 9, soft: 0.30))
    m = max(m, rect(x, y, x0: 850, y0: 330, x1: 1010, y1: 382, feather: 6))
    return clamp(m)
}
func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return NSColor(deviceRed: aa.redComponent * (1 - t) + bb.redComponent * t,
                   green: aa.greenComponent * (1 - t) + bb.greenComponent * t,
                   blue: aa.blueComponent * (1 - t) + bb.blueComponent * t,
                   alpha: aa.alphaComponent * (1 - t) + bb.alphaComponent * t)
}

for y in 300..<425 where y >= 0 && y < height {
    for x in 805..<1038 where x >= 0 && x < width {
        let m = maskAt(x: CGFloat(x), y: CGFloat(y))
        if m > 0,
           let bc = base.colorAt(x: x, y: y),
           let ac = ai.colorAt(x: x, y: y) {
            result.setColor(blend(bc, ac, t: m), atX: x, y: y)
        }
    }
}

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
