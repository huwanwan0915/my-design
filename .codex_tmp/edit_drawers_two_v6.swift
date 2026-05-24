import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v6.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB)!
    let bb = b.usingColorSpace(.deviceRGB)!
    return NSColor(
        deviceRed: aa.redComponent * (1 - t) + bb.redComponent * t,
        green: aa.greenComponent * (1 - t) + bb.greenComponent * t,
        blue: aa.blueComponent * (1 - t) + bb.blueComponent * t,
        alpha: aa.alphaComponent * (1 - t) + bb.alphaComponent * t
    )
}

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

// Verified drawer geometry in image pixel coordinates.
let innerX0 = 832
let innerX1 = 1000
let oldSeam1Top = 584
let oldSeam2Top = 651
let seamBandH = 4
let newSeamTop = 620

func eraseSeamBand(yTop: Int) {
    for y in yTop..<(yTop + seamBandH) {
        let sampleUp = clamp(y - 10, 523, 719)
        let sampleDown = clamp(y + 10, 523, 719)
        for x in innerX0..<innerX1 {
            guard let up = src.colorAt(x: x, y: sampleUp),
                  let down = src.colorAt(x: x, y: sampleDown) else { continue }
            rep.setColor(blend(up, down, t: 0.5), atX: x, y: y)
        }
    }
}

// Remove the original two drawer seams.
eraseSeamBand(yTop: oldSeam1Top)
eraseSeamBand(yTop: oldSeam2Top)

// Copy the original top seam appearance into the new middle position.
for dy in 0..<seamBandH {
    for x in innerX0..<innerX1 {
        if let c = src.colorAt(x: x, y: oldSeam1Top + dy) {
            rep.setColor(c, atX: x, y: newSeamTop + dy)
        }
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
