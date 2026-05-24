import AppKit

let width = 1536
let height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/mouse-removal-mask.png"

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

func setPixel(x: Int, y: Int, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    rep.setColor(NSColor(deviceRed: r, green: g, blue: b, alpha: a), atX: x, y: y)
}

for y in 0..<height {
    for x in 0..<width {
        setPixel(x: x, y: y, r: 1, g: 1, b: 1, a: 1)
    }
}

let cx: CGFloat = 957
let cy: CGFloat = 700
let rx: CGFloat = 62
let ry: CGFloat = 95
for y in 0..<height {
    for x in 0..<width {
        let dx = (CGFloat(x) - cx) / rx
        let dy = (CGFloat(y) - cy) / ry
        if dx * dx + dy * dy <= 1.0 {
            setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0)
        }
    }
}

let url = URL(fileURLWithPath: outputPath)
let data = rep.representation(using: .png, properties: [:])!
try data.write(to: url)
print(outputPath)
