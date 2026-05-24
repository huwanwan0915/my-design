import AppKit
import CoreGraphics

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v3.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat = 1
    var color: NSColor { NSColor(deviceRed: r, green: g, blue: b, alpha: a) }
}

func avgColor(_ rep: NSBitmapImageRep, x: Int, y: Int, w: Int, h: Int) -> RGB {
    let x0 = clamp(x, 0, rep.pixelsWide - 1)
    let y0 = clamp(y, 0, rep.pixelsHigh - 1)
    let x1 = clamp(x + w, 0, rep.pixelsWide)
    let y1 = clamp(y + h, 0, rep.pixelsHigh)
    var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0
    var count: CGFloat = 0
    for yy in y0..<y1 {
        for xx in x0..<x1 {
            guard let c = rep.colorAt(x: xx, y: yy)?.usingColorSpace(.deviceRGB) else { continue }
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

func drawWoodBand(_ ctx: CGContext, rect: CGRect, base: RGB) {
    fill(ctx, rect, base)
    for i in 0..<3 {
        let yy = rect.minY + CGFloat(i) * (rect.height / 3)
        let c = RGB(r: min(base.r + 0.015, 1), g: min(base.g + 0.015, 1), b: min(base.b + 0.01, 1), a: 0.25)
        fill(ctx, CGRect(x: rect.minX, y: yy, width: rect.width, height: 1), c)
    }
    for i in 0..<6 {
        let xx = rect.minX + CGFloat(i) * (rect.width / 6)
        let c = RGB(r: max(base.r - 0.02, 0), g: max(base.g - 0.02, 0), b: max(base.b - 0.015, 0), a: 0.08)
        fill(ctx, CGRect(x: xx, y: rect.minY, width: 1, height: rect.height), c)
    }
}

func imageBandToDrawRect(height: Int, x0: Int, x1: Int, yTop: Int, yBottom: Int) -> CGRect {
    CGRect(x: CGFloat(x0), y: CGFloat(height - yBottom), width: CGFloat(x1 - x0), height: CGFloat(yBottom - yTop))
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

// Drawer face bounds in image coordinates.
let x0 = 832
let x1 = 1000
let topBoundary = 523
let bottomBoundary = 724
let oldSeam1 = 585
let oldSeam2 = 652
let newSeam = Int(round(Double(topBoundary + bottomBoundary) / 2.0))

let wood1 = avgColor(rep, x: x0 + 8, y: oldSeam1 - 18, w: x1 - x0 - 16, h: 12)
let wood2 = avgColor(rep, x: x0 + 8, y: oldSeam2 - 18, w: x1 - x0 - 16, h: 12)
let baseWood = avgColor(rep, x: x0 + 10, y: topBoundary + 22, w: x1 - x0 - 20, h: 50)
let seamDark = RGB(r: max(baseWood.r - 0.16, 0), g: max(baseWood.g - 0.16, 0), b: max(baseWood.b - 0.14, 0), a: 0.70)
let seamHi = RGB(r: min(baseWood.r + 0.05, 1), g: min(baseWood.g + 0.05, 1), b: min(baseWood.b + 0.04, 1), a: 0.25)

let erase1 = imageBandToDrawRect(height: height, x0: x0 + 2, x1: x1 - 2, yTop: oldSeam1 - 4, yBottom: oldSeam1 + 5)
let erase2 = imageBandToDrawRect(height: height, x0: x0 + 2, x1: x1 - 2, yTop: oldSeam2 - 4, yBottom: oldSeam2 + 5)
drawWoodBand(ctx, rect: erase1, base: wood1)
drawWoodBand(ctx, rect: erase2, base: wood2)

let seamY = CGFloat(height - newSeam)
strokeLine(ctx, from: CGPoint(x: CGFloat(x0 + 1), y: seamY), to: CGPoint(x: CGFloat(x1 - 1), y: seamY), color: seamDark, width: 1.2)
strokeLine(ctx, from: CGPoint(x: CGFloat(x0 + 2), y: seamY + 2), to: CGPoint(x: CGFloat(x1 - 2), y: seamY + 2), color: seamHi, width: 0.8)

canvas.unlockFocus()

guard let outTiff = canvas.tiffRepresentation,
      let outRep = NSBitmapImageRep(data: outTiff),
      let png = outRep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
