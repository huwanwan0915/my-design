import AppKit

let originalPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let editedPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v4_书架下柜合成.png"

guard let originalImage = NSImage(contentsOfFile: originalPath),
      let originalTiff = originalImage.tiffRepresentation,
      let original = NSBitmapImageRep(data: originalTiff),
      let editedImage = NSImage(contentsOfFile: editedPath),
      let editedTiff = editedImage.tiffRepresentation,
      let edited = NSBitmapImageRep(data: editedTiff),
      let result = original.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load images")
}

let width = min(original.pixelsWide, edited.pixelsWide)
let height = min(original.pixelsHigh, edited.pixelsHigh)

func smoothstep(_ edge0: CGFloat, _ edge1: CGFloat, _ x: CGFloat) -> CGFloat {
    let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)
}

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return NSColor(deviceRed: aa.redComponent * (1 - t) + bb.redComponent * t,
                   green: aa.greenComponent * (1 - t) + bb.greenComponent * t,
                   blue: aa.blueComponent * (1 - t) + bb.blueComponent * t,
                   alpha: aa.alphaComponent * (1 - t) + bb.alphaComponent * t)
}

let x0 = 812, x1 = 1032
let y0 = 525, y1 = 794
let featherX: CGFloat = 12
let featherTop: CGFloat = 10
let featherBottom: CGFloat = 8

for y in y0..<y1 where y >= 0 && y < height {
    for x in x0..<x1 where x >= 0 && x < width {
        let left = smoothstep(CGFloat(x0), CGFloat(x0) + featherX, CGFloat(x))
        let right = 1 - smoothstep(CGFloat(x1) - featherX, CGFloat(x1), CGFloat(x))
        let top = smoothstep(CGFloat(y0), CGFloat(y0) + featherTop, CGFloat(y))
        let bottom = 1 - smoothstep(CGFloat(y1) - featherBottom, CGFloat(y1), CGFloat(y))
        var t = max(0, min(1, min(min(left, right), min(top, bottom))))
        // Preserve the exact shelf side rails and bottom shadow line.
        if x < x0 + 8 || x > x1 - 8 { t *= 0.45 }
        if t > 0,
           let oc = original.colorAt(x: x, y: y),
           let ec = edited.colorAt(x: x, y: y) {
            result.setColor(blend(oc, ec, t: t), atX: x, y: y)
        }
    }
}

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
