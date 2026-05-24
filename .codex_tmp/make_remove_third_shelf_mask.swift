import AppKit

let width = 1536
let height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/remove-third-shelf-mask.png"

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

// Third internal shelf board from top, separating the middle swan compartment and lower books compartment.
let x0 = 810
let x1 = 1032
let y0 = 430
let y1 = 470
for y in y0..<y1 {
    for x in x0..<x1 {
        setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0)
    }
}

let data = rep.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
