import AppKit

let inputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v4_书架下柜合成.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_右侧门板LR65_v2.png"

guard let image = NSImage(contentsOfFile: inputPath),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let result = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

let width = src.pixelsWide
let height = src.pixelsHigh

func clamp(_ v: CGFloat) -> CGFloat { max(0, min(1, v)) }
func rgb(_ color: NSColor?) -> (CGFloat, CGFloat, CGFloat) {
    guard let c = color?.usingColorSpace(.deviceRGB) else { return (0, 0, 0) }
    return (c.redComponent, c.greenComponent, c.blueComponent)
}
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(deviceRed: clamp(r), green: clamp(g), blue: clamp(b), alpha: clamp(a))
}
func luminance(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGFloat { 0.2126 * r + 0.7152 * g + 0.0722 * b }
func smoothstep(_ edge0: CGFloat, _ edge1: CGFloat, _ x: CGFloat) -> CGFloat {
    let t = clamp((x - edge0) / (edge1 - edge0))
    return t * t * (3 - 2 * t)
}
func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return color(aa.redComponent * (1 - t) + bb.redComponent * t,
                 aa.greenComponent * (1 - t) + bb.greenComponent * t,
                 aa.blueComponent * (1 - t) + bb.blueComponent * t,
                 aa.alphaComponent * (1 - t) + bb.alphaComponent * t)
}

// Door panel to the right of the open bookshelf.
let x0 = 1035, x1 = 1177
let y0 = 174, y1 = 724
let feather: CGFloat = 6

// LR65 tone sampled from clean drawer-face areas, intentionally avoiding horizontal seams.
let sampleRects = [
    (830, 548, 1008, 585),
    (830, 610, 1008, 646),
    (830, 678, 1008, 710)
]
var sr: CGFloat = 0, sg: CGFloat = 0, sb: CGFloat = 0, sc: CGFloat = 0
for rect in sampleRects {
    for y in rect.1..<rect.3 {
        for x in rect.0..<rect.2 {
            let (r, g, b) = rgb(src.colorAt(x: x, y: y))
            sr += r; sg += g; sb += b; sc += 1
        }
    }
}
let baseR = sr / sc
let baseG = sg / sc
let baseB = sb / sc

for y in y0..<y1 where y >= 0 && y < height {
    for x in x0..<x1 where x >= 0 && x < width {
        guard let original = src.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
        let lum = luminance(original.redComponent, original.greenComponent, original.blueComponent)
        let nx = CGFloat(x - x0) / CGFloat(x1 - x0)
        let ny = CGFloat(y - y0) / CGFloat(y1 - y0)

        // Preserve original panel lighting: slightly brighter center, darker right return edge.
        let lighting = (lum - 0.705) * 0.78
        let sideShade = (nx - 0.5) * 0.035
        let topShade = (0.5 - ny) * 0.018

        // Subtle LR65 wood grain without copying drawer horizontal seams.
        let fineGrain = sin(CGFloat(x) * 0.19 + CGFloat(y) * 0.012) * 0.006
        let verticalGrain = sin(CGFloat(x) * 0.047) * 0.010 + sin(CGFloat(x) * 0.083 + 1.7) * 0.006
        let softVariation = sin((CGFloat(x) * 0.018) + (CGFloat(y) * 0.006)) * 0.004
        let grain = fineGrain + verticalGrain + softVariation

        let target = color(baseR + lighting + sideShade + topShade + grain,
                           baseG + lighting + sideShade + topShade + grain * 0.86,
                           baseB + lighting + sideShade + topShade + grain * 0.68)

        let left = smoothstep(CGFloat(x0), CGFloat(x0) + feather, CGFloat(x))
        let right = 1 - smoothstep(CGFloat(x1) - feather, CGFloat(x1), CGFloat(x))
        let top = smoothstep(CGFloat(y0), CGFloat(y0) + feather, CGFloat(y))
        let bottom = 1 - smoothstep(CGFloat(y1) - feather, CGFloat(y1), CGFloat(y))
        let mask = min(min(left, right), min(top, bottom))
        result.setColor(blend(original, target, t: mask), atX: x, y: y)
    }
}

// Keep only the original vertical door boundaries; no horizontal grooves.
for x in [x0, x1 - 1] {
    for y in y0..<y1 where x >= 0 && x < width && y >= 0 && y < height {
        if let current = result.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) {
            result.setColor(color(current.redComponent * 0.86, current.greenComponent * 0.86, current.blueComponent * 0.86), atX: x, y: y)
        }
    }
}

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
