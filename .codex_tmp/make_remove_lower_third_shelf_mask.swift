import AppKit
let width = 1536, height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/remove-lower-third-shelf-and-decor-mask.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
func set(_ x: Int, _ y: Int, _ a: CGFloat) { rep.setColor(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: a), atX: x, y: y) }
for y in 0..<height { for x in 0..<width { set(x, y, 1) } }
// Third shelf from top if counting internal shelves: the board carrying the books and small vase, plus the objects on it.
// Keep the two shelf boards above unchanged by leaving them outside the transparent mask.
for y in 438..<548 { for x in 812..<1030 { set(x, y, 0) } }
let data = rep.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
