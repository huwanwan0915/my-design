import AppKit

let width = 1536
let height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/right-white-panel-mask.png"

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

// Door panel immediately to the right of the open bookshelf, excluding surrounding wall/opening.
let x0 = 1034
let x1 = 1178
let y0 = 174
let y1 = 724
for y in y0..<y1 {
    for x in x0..<x1 {
        setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0)
    }
}

let data = rep.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
