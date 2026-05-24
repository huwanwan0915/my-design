import AppKit
let width = 1536, height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/remove-third-shelf-middle-cubby-mask.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
func set(_ x: Int, _ y: Int, _ a: CGFloat) { rep.setColor(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: a), atX: x, y: y) }
for y in 0..<height { for x in 0..<width { set(x, y, 1) } }
// Redraw only the middle open cubby: below the second shelf, above the lower books shelf.
// This gives the model room to remove the third shelf and swan decor cleanly while keeping upper/lower shelves outside the mask.
for y in 255..<520 { for x in 810..<1032 { set(x, y, 0) } }
let data = rep.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
