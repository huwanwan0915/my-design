import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_v11.png"

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

func avgColor(x0: Int, y0: Int, x1: Int, y1: Int) -> NSColor {
    var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
    var count: CGFloat = 0
    for y in y0..<y1 {
        for x in x0..<x1 {
            guard let c = src.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
            rr += c.redComponent
            gg += c.greenComponent
            bb += c.blueComponent
            aa += c.alphaComponent
            count += 1
        }
    }
    if count == 0 { return NSColor(deviceRed: 0.5, green: 0.5, blue: 0.5, alpha: 1) }
    return NSColor(deviceRed: rr / count, green: gg / count, blue: bb / count, alpha: aa / count)
}

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

// Mouse area in source image coordinates.
let x0 = 920
let x1 = 992
let y0 = 647
let y1 = 776
let deskTopY = 719

let wallTop = avgColor(x0: 930, y0: 654, x1: 980, y1: 700)
let drawerMid = avgColor(x0: 860, y0: 680, x1: 900, y1: 710)
let darkDesk = avgColor(x0: 900, y0: 723, x1: 980, y1: 760)
let darkDeskEdge = avgColor(x0: 980, y0: 740, x1: 1010, y1: 775)

for y in y0..<y1 {
    for x in x0..<x1 {
        let fill: NSColor
        if y < deskTopY - 4 {
            let t = CGFloat(y - y0) / CGFloat((deskTopY - 4) - y0)
            fill = blend(drawerMid, wallTop, t: max(0, min(1, t * 0.65)))
        } else if y < deskTopY + 14 {
            fill = darkDesk
        } else {
            let edgeBias = x > 975 ? 0.35 : 0.15
            fill = blend(darkDesk, darkDeskEdge, t: edgeBias)
        }
        rep.setColor(fill, atX: x, y: y)
    }
}

// Rebuild the visible horizontal drawer seam that ran behind the mouse.
if let seamDark = src.colorAt(x: 945, y: 686), let seamLight = src.colorAt(x: 945, y: 687) {
    for x in x0..<x1 {
        rep.setColor(seamDark, atX: x, y: 686)
        rep.setColor(seamLight, atX: x, y: 687)
    }
}

// Light cleanup around left and right edges of the patched area.
for y in y0..<y1 {
    if let leftNeighbor = src.colorAt(x: x0 - 1, y: y) {
        rep.setColor(leftNeighbor, atX: x0, y: y)
    }
    if let rightNeighbor = src.colorAt(x: x1, y: y) {
        rep.setColor(rightNeighbor, atX: x1 - 1, y: y)
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
