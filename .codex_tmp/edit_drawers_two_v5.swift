import AppKit
import CoreGraphics

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v5.png"

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat = 1
    var color: NSColor { NSColor(deviceRed: r, green: g, blue: b, alpha: a) }
}

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

func avgColor(_ rep: NSBitmapImageRep, _ rect: CGRect) -> RGB {
    let x0 = clamp(Int(rect.minX), 0, rep.pixelsWide - 1)
    let y0 = clamp(Int(rect.minY), 0, rep.pixelsHigh - 1)
    let x1 = clamp(Int(rect.maxX), 0, rep.pixelsWide)
    let y1 = clamp(Int(rect.maxY), 0, rep.pixelsHigh)
    var rr: CGFloat = 0
    var gg: CGFloat = 0
    var bb: CGFloat = 0
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

func stroke(_ ctx: CGContext, y: CGFloat, x0: CGFloat, x1: CGFloat, color: RGB, width: CGFloat) {
    ctx.setStrokeColor(color.color.cgColor)
    ctx.setLineWidth(width)
    ctx.move(to: CGPoint(x: x0, y: y))
    ctx.addLine(to: CGPoint(x: x1, y: y))
    ctx.strokePath()
}

func drawWoodBand(_ ctx: CGContext, rect: CGRect, base: RGB) {
    fill(ctx, rect, base)
    let hi = RGB(r: min(base.r + 0.02, 1), g: min(base.g + 0.02, 1), b: min(base.b + 0.015, 1), a: 0.35)
    let lo = RGB(r: max(base.r - 0.02, 0), g: max(base.g - 0.02, 0), b: max(base.b - 0.015, 0), a: 0.18)
    fill(ctx, CGRect(x: rect.minX, y: rect.maxY - 2, width: rect.width, height: 1), hi)
    fill(ctx, CGRect(x: rect.minX, y: rect.minY + 2, width: rect.width, height: 1), hi)
    for i in 0..<5 {
        let x = rect.minX + CGFloat(i) * (rect.width / 5)
        fill(ctx, CGRect(x: x, y: rect.minY, width: 1, height: rect.height), lo)
    }
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

// Drawer stack bounds in image coordinates from the source image.
let drawerX0: CGFloat = 832
let drawerX1: CGFloat = 1000
let stackTopImage: CGFloat = 523
let stackBottomImage: CGFloat = 724
let oldSeam1Image: CGFloat = 585
let oldSeam2Image: CGFloat = 652
let newSeamImage: CGFloat = (stackTopImage + stackBottomImage) / 2

// Convert image-space y (top-origin) to drawing-space y (bottom-origin).
func drawY(_ imageY: CGFloat) -> CGFloat { CGFloat(height) - imageY }

let woodBase = avgColor(rep, CGRect(x: 850, y: 540, width: 120, height: 60))
let woodTop = avgColor(rep, CGRect(x: 850, y: 560, width: 120, height: 12))
let woodBottom = avgColor(rep, CGRect(x: 850, y: 627, width: 120, height: 12))
let seamDark = RGB(r: max(woodBase.r - 0.16, 0), g: max(woodBase.g - 0.16, 0), b: max(woodBase.b - 0.14, 0), a: 0.75)
let seamHi = RGB(r: min(woodBase.r + 0.05, 1), g: min(woodBase.g + 0.05, 1), b: min(woodBase.b + 0.04, 1), a: 0.35)

// Cover the two old seams with wood-tone bands only within the drawer face.
let eraseH: CGFloat = 10
let erase1 = CGRect(x: drawerX0 + 1, y: drawY(oldSeam1Image + eraseH / 2), width: drawerX1 - drawerX0 - 2, height: eraseH)
let erase2 = CGRect(x: drawerX0 + 1, y: drawY(oldSeam2Image + eraseH / 2), width: drawerX1 - drawerX0 - 2, height: eraseH)
drawWoodBand(ctx, rect: erase1, base: woodTop)
drawWoodBand(ctx, rect: erase2, base: woodBottom)

// Draw one new middle seam so the original three drawers become two taller drawers.
let seamY = drawY(newSeamImage)
stroke(ctx, y: seamY, x0: drawerX0 + 1, x1: drawerX1 - 1, color: seamDark, width: 1.2)
stroke(ctx, y: seamY - 2, x0: drawerX0 + 2, x1: drawerX1 - 2, color: seamHi, width: 0.8)

canvas.unlockFocus()

guard let outTiff = canvas.tiffRepresentation,
      let outRep = NSBitmapImageRep(data: outTiff),
      let png = outRep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
