import AppKit

let originalPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let editedPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1_局部合成.png"

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
let cx: CGFloat = 957
let cy: CGFloat = 700
let rx: CGFloat = 58
let ry: CGFloat = 88
let feather: CGFloat = 0.18

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return NSColor(
        deviceRed: aa.redComponent * (1 - t) + bb.redComponent * t,
        green: aa.greenComponent * (1 - t) + bb.greenComponent * t,
        blue: aa.blueComponent * (1 - t) + bb.blueComponent * t,
        alpha: aa.alphaComponent * (1 - t) + bb.alphaComponent * t
    )
}

for y in 0..<height {
    for x in 0..<width {
        let dx = (CGFloat(x) - cx) / rx
        let dy = (CGFloat(y) - cy) / ry
        let d = sqrt(dx * dx + dy * dy)
        if d <= 1.0,
           let oc = original.colorAt(x: x, y: y),
           let ec = edited.colorAt(x: x, y: y) {
            let t: CGFloat
            if d <= 1.0 - feather {
                t = 1.0
            } else {
                t = max(0, min(1, (1.0 - d) / feather))
            }
            result.setColor(blend(oc, ec, t: t), atX: x, y: y)
        }
    }
}

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
