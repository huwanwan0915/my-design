import AppKit

let width = 1536
let height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/remove-third-shelf-and-decor-mask.png"

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
for y in 0..<height { for x in 0..<width { setPixel(x: x, y: y, r: 1, g: 1, b: 1, a: 1) } }
func clearRect(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int) {
    for y in max(0, y0)..<min(height, y1) { for x in max(0, x0)..<min(width, x1) { setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0) } }
}
func clearEllipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) {
    let x0 = Int(cx - rx - 2), x1 = Int(cx + rx + 2)
    let y0 = Int(cy - ry - 2), y1 = Int(cy + ry + 2)
    for y in max(0, y0)..<min(height, y1) {
        for x in max(0, x0)..<min(width, x1) {
            let dx = (CGFloat(x) - cx) / rx
            let dy = (CGFloat(y) - cy) / ry
            if dx * dx + dy * dy <= 1 { setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0) }
        }
    }
}
func clearCapsule(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, r: CGFloat) {
    let minX = Int(min(x1, x2) - r - 2), maxX = Int(max(x1, x2) + r + 2)
    let minY = Int(min(y1, y2) - r - 2), maxY = Int(max(y1, y2) + r + 2)
    let vx = x2 - x1, vy = y2 - y1
    for y in max(0, minY)..<min(height, maxY) {
        for x in max(0, minX)..<min(width, maxX) {
            let wx = CGFloat(x) - x1, wy = CGFloat(y) - y1
            let t = max(0, min(1, (wx * vx + wy * vy) / (vx * vx + vy * vy)))
            let px = x1 + t * vx, py = y1 + t * vy
            let dx = CGFloat(x) - px, dy = CGFloat(y) - py
            if sqrt(dx * dx + dy * dy) <= r { setPixel(x: x, y: y, r: 0, g: 0, b: 0, a: 0) }
        }
    }
}

// Third shelf board from top: the board directly under the swan decor.
clearRect(810, 385, 1032, 420)

// Decor sitting on that third shelf: white swan pair and black curved stand.
clearEllipse(cx: 910, cy: 350, rx: 72, ry: 38)
clearEllipse(cx: 965, cy: 352, rx: 55, ry: 34)
clearCapsule(x1: 840, y1: 352, x2: 1015, y2: 352, r: 8)
clearCapsule(x1: 842, y1: 348, x2: 875, y2: 372, r: 7)
clearCapsule(x1: 1015, y1: 348, x2: 984, y2: 372, r: 7)
clearCapsule(x1: 925, y1: 318, x2: 915, y2: 350, r: 8)
clearCapsule(x1: 970, y1: 327, x2: 955, y2: 354, r: 8)
clearRect(850, 330, 1010, 382)

let data = rep.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
