import AppKit

let inputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v4_书架下柜合成.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_右侧门板LR65_v1.png"

guard let image = NSImage(contentsOfFile: inputPath),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let result = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

let width = src.pixelsWide
let height = src.pixelsHigh

func rgb(_ color: NSColor?) -> (CGFloat, CGFloat, CGFloat) {
    guard let c = color?.usingColorSpace(.deviceRGB) else { return (0, 0, 0) }
    return (c.redComponent, c.greenComponent, c.blueComponent)
}

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    return NSColor(deviceRed: max(0, min(1, r)), green: max(0, min(1, g)), blue: max(0, min(1, b)), alpha: a)
}

func luminance(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGFloat {
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

func smoothstep(_ edge0: CGFloat, _ edge1: CGFloat, _ x: CGFloat) -> CGFloat {
    if edge0 == edge1 { return x < edge0 ? 0 : 1 }
    let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)
}

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return color(
        aa.redComponent * (1 - t) + bb.redComponent * t,
        aa.greenComponent * (1 - t) + bb.greenComponent * t,
        aa.blueComponent * (1 - t) + bb.blueComponent * t,
        aa.alphaComponent * (1 - t) + bb.alphaComponent * t
    )
}

// Target: flat door panel immediately to the right of the bookshelf/open shelf.
let x0 = 1035
let x1 = 1177
let y0 = 174
let y1 = 724
let feather: CGFloat = 7

// LR65 sample from existing lower wood drawers in the same image.
let sampleX0 = 820
let sampleX1 = 1018
let sampleY0 = 532
let sampleY1 = 724

var sr: CGFloat = 0, sg: CGFloat = 0, sb: CGFloat = 0, sy: CGFloat = 0
var count: CGFloat = 0
for y in sampleY0..<sampleY1 {
    for x in sampleX0..<sampleX1 {
        let (r, g, b) = rgb(src.colorAt(x: x, y: y))
        sr += r; sg += g; sb += b; sy += luminance(r, g, b); count += 1
    }
}
let avgR = sr / count
let avgG = sg / count
let avgB = sb / count
let avgLum = sy / count

for y in y0..<y1 where y >= 0 && y < height {
    for x in x0..<x1 where x >= 0 && x < width {
        guard let original = src.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
        let (or, og, ob) = (original.redComponent, original.greenComponent, original.blueComponent)
        let originalLum = luminance(or, og, ob)
        let sampleX = sampleX0 + (x - x0) % (sampleX1 - sampleX0)
        let sampleY = sampleY0 + (y - y0) % (sampleY1 - sampleY0)
        let (wr0, wg0, wb0) = rgb(src.colorAt(x: sampleX, y: sampleY))
        let woodLum = luminance(wr0, wg0, wb0)
        let grain = woodLum - avgLum

        // Preserve the existing large-scale light/shadow on the white panel while replacing material hue.
        let shade = (originalLum - 0.70) * 0.72
        let verticalShade = (CGFloat(x - x0) / CGFloat(x1 - x0) - 0.5) * 0.030
        let finalR = avgR + grain * 0.72 + shade + verticalShade
        let finalG = avgG + grain * 0.66 + shade + verticalShade
        let finalB = avgB + grain * 0.54 + shade + verticalShade
        var target = color(finalR, finalG, finalB)

        // Keep very subtle vertical wood grain from the sampled LR65 drawers.
        if (x - x0) % 37 == 0 || (x - x0 + 11) % 53 == 0 {
            target = blend(target, color(finalR - 0.018, finalG - 0.015, finalB - 0.012), t: 0.35)
        }

        let left = smoothstep(CGFloat(x0), CGFloat(x0) + feather, CGFloat(x))
        let right = 1 - smoothstep(CGFloat(x1) - feather, CGFloat(x1), CGFloat(x))
        let top = smoothstep(CGFloat(y0), CGFloat(y0) + feather, CGFloat(y))
        let bottom = 1 - smoothstep(CGFloat(y1) - feather, CGFloat(y1), CGFloat(y))
        let mask = max(0, min(1, min(min(left, right), min(top, bottom))))
        result.setColor(blend(original, target, t: mask), atX: x, y: y)
    }
}

// Reinforce original door seams so the cabinet reads as the same panel, just LR65-colored.
func drawLine(x: Int, fromY: Int, toY: Int, alpha: CGFloat) {
    for y in fromY..<toY where y >= 0 && y < height && x >= 0 && x < width {
        if let oc = result.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) {
            let seam = color(oc.redComponent * 0.82, oc.greenComponent * 0.82, oc.blueComponent * 0.82)
            result.setColor(blend(oc, seam, t: alpha), atX: x, y: y)
        }
    }
}
drawLine(x: x0, fromY: y0, toY: y1, alpha: 0.35)
drawLine(x: x1 - 1, fromY: y0, toY: y1, alpha: 0.22)

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
