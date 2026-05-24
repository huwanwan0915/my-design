import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v4.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

func avgColor(_ rep: NSBitmapImageRep, x0: Int, x1: Int, y0: Int, y1: Int) -> NSColor {
    var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
    var count: CGFloat = 0
    for y in y0..<y1 {
        for x in x0..<x1 {
            guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
            rr += c.redComponent
            gg += c.greenComponent
            bb += c.blueComponent
            aa += c.alphaComponent
            count += 1
        }
    }
    if count == 0 { return NSColor(deviceRed: 0.82, green: 0.77, blue: 0.72, alpha: 1) }
    return NSColor(deviceRed: rr / count, green: gg / count, blue: bb / count, alpha: aa / count)
}

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

let w = rep.pixelsWide
let h = rep.pixelsHigh

// Drawer area in image coordinates (top-left origin style as observed from source image)
let x0 = 832
let x1 = 999
let stackTop = 523
let stackBottom = 724
let oldSeam1 = 585
let oldSeam2 = 652
let newSeam = 624

func copyBand(yStart: Int, yEnd: Int, sampleOffset: Int) {
    for y in yStart...yEnd {
        let sy = clamp(y + sampleOffset, stackTop + 8, stackBottom - 8)
        for x in (x0 + 2)..<(x1 - 2) {
            if let c = src.colorAt(x: x, y: sy) {
                rep.setColor(c, atX: x, y: y)
            }
        }
    }
}

// Remove the two old seam bands by copying nearby wood rows.
copyBand(yStart: oldSeam1 - 5, yEnd: oldSeam1 + 6, sampleOffset: -24)
copyBand(yStart: oldSeam2 - 5, yEnd: oldSeam2 + 6, sampleOffset: -24)

let seamBase = avgColor(src, x0: x0 + 10, x1: x1 - 10, y0: 545, y1: 565).usingColorSpace(.deviceRGB)!
let dark = NSColor(deviceRed: max(seamBase.redComponent - 0.17, 0), green: max(seamBase.greenComponent - 0.17, 0), blue: max(seamBase.blueComponent - 0.15, 0), alpha: 1)
let light = NSColor(deviceRed: min(seamBase.redComponent + 0.04, 1), green: min(seamBase.greenComponent + 0.04, 1), blue: min(seamBase.blueComponent + 0.03, 1), alpha: 1)

// Draw the single new seam centered in the full original drawer stack.
for x in (x0 + 1)..<(x1 - 1) {
    rep.setColor(dark, atX: x, y: newSeam)
    rep.setColor(light, atX: x, y: newSeam + 1)
}

// Slightly soften one row above and below the new seam for a natural recess effect.
for x in (x0 + 2)..<(x1 - 2) {
    if let topC = src.colorAt(x: x, y: newSeam - 18)?.blended(withFraction: 0.20, of: dark) {
        rep.setColor(topC, atX: x, y: newSeam - 1)
    }
    if let botC = src.colorAt(x: x, y: newSeam + 18)?.blended(withFraction: 0.10, of: light) {
        rep.setColor(botC, atX: x, y: newSeam + 2)
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
