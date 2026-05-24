import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v7.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

func rgb(_ c: NSColor?) -> NSColor? { c?.usingColorSpace(.deviceRGB) }

func brightness(_ c: NSColor) -> CGFloat {
    (c.redComponent + c.greenComponent + c.blueComponent) / 3
}

func woodLike(_ c: NSColor) -> Bool {
    let maxCh = max(c.redComponent, max(c.greenComponent, c.blueComponent))
    let minCh = min(c.redComponent, min(c.greenComponent, c.blueComponent))
    let spread = maxCh - minCh
    let b = brightness(c)
    return b > 0.58 && b < 0.86 && spread < 0.12 && c.redComponent + 0.02 >= c.greenComponent && c.greenComponent + 0.04 >= c.blueComponent
}

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
let x0 = 833
let x1 = 998
let oldSeam1 = 585
let oldSeam2 = 652
let newSeam = 619
let seamBand = 4

func isWoodColumnPixel(_ x: Int, _ y: Int) -> Bool {
    for dy in [-10, -6, -2, 2, 6, 10] {
        let yy = clamp(y + dy, 0, src.pixelsHigh - 1)
        if let c = rgb(src.colorAt(x: x, y: yy)), woodLike(c) {
            return true
        }
    }
    return false
}

func eraseOldSeam(at seamY: Int) {
    for y in (seamY - 2)...(seamY + 2) {
        for x in x0...x1 {
            guard isWoodColumnPixel(x, y) else { continue }
            let upY = clamp(y - 10, 0, src.pixelsHigh - 1)
            let downY = clamp(y + 10, 0, src.pixelsHigh - 1)
            guard let up = rgb(src.colorAt(x: x, y: upY)),
                  let down = rgb(src.colorAt(x: x, y: downY)) else { continue }
            let fill: NSColor
            if woodLike(up) && woodLike(down) {
                fill = blend(up, down, t: 0.5)
            } else if woodLike(up) {
                fill = up
            } else if woodLike(down) {
                fill = down
            } else {
                continue
            }
            rep.setColor(fill, atX: x, y: y)
        }
    }
}

eraseOldSeam(at: oldSeam1)
eraseOldSeam(at: oldSeam2)

// Reuse the original upper seam pixels at the new middle position so the style matches exactly.
for dy in 0..<seamBand {
    for x in x0...x1 {
        guard isWoodColumnPixel(x, newSeam + dy) else { continue }
        if let c = src.colorAt(x: x, y: oldSeam1 + dy) {
            rep.setColor(c, atX: x, y: newSeam + dy)
        }
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
