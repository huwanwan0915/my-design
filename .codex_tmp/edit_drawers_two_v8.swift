import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v8.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

func rgb(_ c: NSColor?) -> NSColor? { c?.usingColorSpace(.deviceRGB) }

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    NSColor(
        deviceRed: a.redComponent * (1 - t) + b.redComponent * t,
        green: a.greenComponent * (1 - t) + b.greenComponent * t,
        blue: a.blueComponent * (1 - t) + b.blueComponent * t,
        alpha: a.alphaComponent * (1 - t) + b.alphaComponent * t
    )
}

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

// Verified drawer-face geometry in source image coordinates.
let x0 = 832
let x1 = 999
let oldSeam1 = 585
let oldSeam2 = 652
let newSeam = 619

func eraseSeam(y: Int, xStart: Int, xEnd: Int) {
    for yy in (y - 2)...(y + 2) {
        for x in xStart...xEnd {
            let upY = clamp(yy - 10, 0, src.pixelsHigh - 1)
            let downY = clamp(yy + 10, 0, src.pixelsHigh - 1)
            guard let up = rgb(src.colorAt(x: x, y: upY)),
                  let down = rgb(src.colorAt(x: x, y: downY)) else { continue }
            rep.setColor(blend(up, down, t: 0.5), atX: x, y: yy)
        }
    }
}

// Remove the first seam across the full visible drawer width.
eraseSeam(y: oldSeam1, xStart: x0, xEnd: x1)

// Remove the second seam only in the visible drawer areas, avoiding the robot overlap.
eraseSeam(y: oldSeam2, xStart: x0, xEnd: 906)
eraseSeam(y: oldSeam2, xStart: 972, xEnd: x1)

// Rebuild one clean middle seam using the original seam tone.
for x in x0...x1 {
    if let dark = rgb(src.colorAt(x: x, y: oldSeam1)),
       let light = rgb(src.colorAt(x: x, y: oldSeam1 + 1)) {
        rep.setColor(dark, atX: x, y: newSeam)
        rep.setColor(light, atX: x, y: newSeam + 1)
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
