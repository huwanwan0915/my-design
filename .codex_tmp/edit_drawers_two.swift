import AppKit
import CoreGraphics

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v2.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat = 1
    var color: NSColor { NSColor(deviceRed: r, green: g, blue: b, alpha: a) }
}

func avgColor(_ rep: NSBitmapImageRep, _ rect: CGRect) -> RGB {
    let x0 = clamp(Int(rect.minX), 0, rep.pixelsWide - 1)
    let y0 = clamp(Int(rect.minY), 0, rep.pixelsHigh - 1)
    let x1 = clamp(Int(rect.maxX), 0, rep.pixelsWide)
    let y1 = clamp(Int(rect.maxY), 0, rep.pixelsHigh)
    var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0
    var count: CGFloat = 0
    for y in y0..<y1 {
        for x in x0..<x1 {
            guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
            rr += c.redComponent
            gg += c.greenComponent
            bb += c.blueComponent
            count += 1
        }
    }
    if count == 0 { return RGB(r: 0.82, g: 0.77, b: 0.72) }
    return RGB(r: rr / count, g: gg / count, b: bb / count)
}

func fill(_ ctx: CGContext, _ rect: CGRect, _ color: RGB) {
    ctx.setFillColor(color.color.cgColor)
    ctx.fill(rect)
}

func strokeLine(_ ctx: CGContext, from: CGPoint, to: CGPoint, color: RGB, width: CGFloat) {
    ctx.setStrokeColor(color.color.cgColor)
    ctx.setLineWidth(width)
    ctx.move(to: from)
    ctx.addLine(to: to)
    ctx.strokePath()
}

func softWood(_ ctx: CGContext, rect: CGRect, base: RGB) {
    fill(ctx, rect, base)
    ctx.saveGState()
    ctx.clip(to: rect)
    for i in 0..<18 {
        let y = rect.minY + CGFloat(i) * (rect.height / 18)
        let alpha: CGFloat = i % 2 == 0 ? 0.06 : 0.03
        fill(ctx, CGRect(x: rect.minX, y: y, width: rect.width, height: rect.height / 24), RGB(r: base.r + 0.03, g: base.g + 0.03, b: base.b + 0.02, a: alpha))
    }
    for i in 0..<10 {
        let x = rect.minX + CGFloat(i) * (rect.width / 10)
        fill(ctx, CGRect(x: x, y: rect.minY, width: 1, height: rect.height), RGB(r: base.r - 0.03, g: base.g - 0.03, b: base.b - 0.02, a: 0.04))
    }
    ctx.restoreGState()
}

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff) else {
    fatalError("Unable to load image")
}

let width = rep.pixelsWide
let height = rep.pixelsHigh
let canvas = NSImage(size: NSSize(width: width, height: height))
canvas.lockFocus()
image.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("No context") }

// Bookshelf box detected earlier in this image family: x 821...1154, y 175...725 in image coordinates.
// Only modify the drawer stack on the left bay.
let drawerLeft: CGFloat = 831
let drawerRight: CGFloat = 1002
let drawerTopImage: CGFloat = 507
let drawerBottomImage: CGFloat = 724

let drawY = CGFloat(height) - drawerBottomImage
let drawerRect = CGRect(x: drawerLeft, y: drawY, width: drawerRight - drawerLeft, height: drawerBottomImage - drawerTopImage)

let base = avgColor(rep, CGRect(x: drawerLeft + 18, y: drawerTopImage + 18, width: 110, height: 120))
let seamDark = RGB(r: max(base.r - 0.14, 0), g: max(base.g - 0.14, 0), b: max(base.b - 0.12, 0), a: 0.55)
let edgeDark = RGB(r: max(base.r - 0.18, 0), g: max(base.g - 0.18, 0), b: max(base.b - 0.16, 0), a: 0.35)
let hi = RGB(r: min(base.r + 0.05, 1), g: min(base.g + 0.05, 1), b: min(base.b + 0.04, 1), a: 0.30)

softWood(ctx, rect: drawerRect, base: base)

let midY = drawerRect.minY + drawerRect.height / 2

// keep original outer frame feel
strokeLine(ctx, from: CGPoint(x: drawerRect.minX, y: drawerRect.maxY - 1), to: CGPoint(x: drawerRect.maxX, y: drawerRect.maxY - 1), color: seamDark, width: 1)
strokeLine(ctx, from: CGPoint(x: drawerRect.minX, y: drawerRect.minY + 1), to: CGPoint(x: drawerRect.maxX, y: drawerRect.minY + 1), color: edgeDark, width: 1)
strokeLine(ctx, from: CGPoint(x: drawerRect.minX + 0.5, y: drawerRect.minY), to: CGPoint(x: drawerRect.minX + 0.5, y: drawerRect.maxY), color: edgeDark, width: 1)
strokeLine(ctx, from: CGPoint(x: drawerRect.maxX - 0.5, y: drawerRect.minY), to: CGPoint(x: drawerRect.maxX - 0.5, y: drawerRect.maxY), color: edgeDark, width: 1)

// one middle seam for two larger drawers
strokeLine(ctx, from: CGPoint(x: drawerRect.minX, y: midY), to: CGPoint(x: drawerRect.maxX, y: midY), color: seamDark, width: 1.2)
strokeLine(ctx, from: CGPoint(x: drawerRect.minX, y: midY + 2), to: CGPoint(x: drawerRect.maxX, y: midY + 2), color: hi, width: 0.8)

// subtle top highlights per drawer face
let topInset: CGFloat = 4
let face1 = CGRect(x: drawerRect.minX, y: midY, width: drawerRect.width, height: drawerRect.maxY - midY)
let face2 = CGRect(x: drawerRect.minX, y: drawerRect.minY, width: drawerRect.width, height: midY - drawerRect.minY)
fill(ctx, CGRect(x: face1.minX + 2, y: face1.maxY - topInset, width: face1.width - 4, height: 2), hi)
fill(ctx, CGRect(x: face2.minX + 2, y: face2.maxY - topInset, width: face2.width - 4, height: 2), hi)

canvas.unlockFocus()

guard let outTiff = canvas.tiffRepresentation,
      let outRep = NSBitmapImageRep(data: outTiff),
      let png = outRep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
