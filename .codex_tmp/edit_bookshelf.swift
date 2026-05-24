import AppKit
import CoreGraphics

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_副本.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_副本_书架全黑_去蓝框_v6.png"

func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat = 1
    var color: NSColor { NSColor(deviceRed: r, green: g, blue: b, alpha: a) }
}

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [NSPoint](repeating: .zero, count: 3)
        for i in 0..<elementCount {
            switch element(at: i, associatedPoints: &points) {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }
        return path
    }
}

func avgColor(_ rep: NSBitmapImageRep, _ rect: CGRect) -> RGB {
    let x0 = clamp(Int(rect.minX), 0, rep.pixelsWide - 1)
    let y0 = clamp(Int(rect.minY), 0, rep.pixelsHigh - 1)
    let x1 = clamp(Int(rect.maxX), 0, rep.pixelsWide)
    let y1 = clamp(Int(rect.maxY), 0, rep.pixelsHigh)
    var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0
    var count: CGFloat = 0
    if x1 <= x0 || y1 <= y0 { return RGB(r: 0.8, g: 0.8, b: 0.8) }
    for y in y0..<y1 {
        for x in x0..<x1 {
            guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
            rr += c.redComponent
            gg += c.greenComponent
            bb += c.blueComponent
            count += 1
        }
    }
    if count == 0 { return RGB(r: 0.8, g: 0.8, b: 0.8) }
    return RGB(r: rr / count, g: gg / count, b: bb / count)
}

func drawGradient(_ ctx: CGContext, _ rect: CGRect, _ top: RGB, _ bottom: RGB) {
    let cs = CGColorSpaceCreateDeviceRGB()
    let colors = [top.color.cgColor, bottom.color.cgColor] as CFArray
    let grad = CGGradient(colorsSpace: cs, colors: colors, locations: [0,1])!
    ctx.saveGState()
    ctx.addRect(rect)
    ctx.clip()
    ctx.drawLinearGradient(grad, start: CGPoint(x: rect.midX, y: rect.maxY), end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    ctx.restoreGState()
}

func fill(_ ctx: CGContext, _ rect: CGRect, _ color: RGB) {
    ctx.setFillColor(color.color.cgColor)
    ctx.fill(rect)
}

func stroke(_ ctx: CGContext, _ rect: CGRect, _ color: RGB, _ width: CGFloat) {
    ctx.setStrokeColor(color.color.cgColor)
    ctx.setLineWidth(width)
    ctx.stroke(rect)
}

func drawSoftShadow(_ ctx: CGContext, rect: CGRect, blur: CGFloat, alpha: CGFloat) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -1), blur: blur, color: NSColor(calibratedWhite: 0, alpha: alpha).cgColor)
    ctx.setFillColor(NSColor.clear.cgColor)
    ctx.fill(rect)
    ctx.restoreGState()
}

func drawBookStack(_ ctx: CGContext, at origin: CGPoint, width: CGFloat) {
    let colors = [
        RGB(r: 0.93, g: 0.93, b: 0.91),
        RGB(r: 0.88, g: 0.89, b: 0.90),
        RGB(r: 0.95, g: 0.94, b: 0.92),
        RGB(r: 0.90, g: 0.90, b: 0.88)
    ]
    var y = origin.y
    for (i,c) in colors.enumerated() {
        let h: CGFloat = i == 0 ? 10 : 8
        fill(ctx, CGRect(x: origin.x + CGFloat(i % 2) * 2, y: y, width: width - CGFloat(i % 2) * 4, height: h), c)
        stroke(ctx, CGRect(x: origin.x + CGFloat(i % 2) * 2, y: y, width: width - CGFloat(i % 2) * 4, height: h), RGB(r: 0.75, g: 0.75, b: 0.73), 0.5)
        y += h + 2
    }
}

func drawVase(_ ctx: CGContext, center: CGPoint, scale: CGFloat) {
    let path = NSBezierPath()
    path.move(to: CGPoint(x: center.x - 7*scale, y: center.y))
    path.curve(to: CGPoint(x: center.x - 3*scale, y: center.y + 15*scale), controlPoint1: CGPoint(x: center.x - 8*scale, y: center.y + 4*scale), controlPoint2: CGPoint(x: center.x - 5*scale, y: center.y + 10*scale))
    path.curve(to: CGPoint(x: center.x - 1*scale, y: center.y + 24*scale), controlPoint1: CGPoint(x: center.x - 2*scale, y: center.y + 17*scale), controlPoint2: CGPoint(x: center.x - 2*scale, y: center.y + 21*scale))
    path.line(to: CGPoint(x: center.x + 1*scale, y: center.y + 24*scale))
    path.curve(to: CGPoint(x: center.x + 3*scale, y: center.y + 15*scale), controlPoint1: CGPoint(x: center.x + 2*scale, y: center.y + 21*scale), controlPoint2: CGPoint(x: center.x + 2*scale, y: center.y + 17*scale))
    path.curve(to: CGPoint(x: center.x + 7*scale, y: center.y), controlPoint1: CGPoint(x: center.x + 5*scale, y: center.y + 10*scale), controlPoint2: CGPoint(x: center.x + 8*scale, y: center.y + 4*scale))
    path.close()
    ctx.setFillColor(NSColor(calibratedRed: 0.90, green: 0.84, blue: 0.78, alpha: 1).cgColor)
    ctx.addPath(path.cgPath)
    ctx.fillPath()
}

func drawBranches(_ ctx: CGContext, start: CGPoint, scale: CGFloat) {
    ctx.saveGState()
    ctx.setStrokeColor(NSColor(calibratedRed: 0.42, green: 0.25, blue: 0.20, alpha: 1).cgColor)
    ctx.setLineWidth(1.3 * scale)
    let branches = [
        (CGPoint(x: 0, y: 0), CGPoint(x: -12, y: 18), CGPoint(x: -20, y: 38)),
        (CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 16), CGPoint(x: 16, y: 34)),
        (CGPoint(x: 0, y: 0), CGPoint(x: -2, y: 20), CGPoint(x: 0, y: 42))
    ]
    for b in branches {
        ctx.move(to: CGPoint(x: start.x + b.0.x*scale, y: start.y + b.0.y*scale))
        ctx.addQuadCurve(to: CGPoint(x: start.x + b.2.x*scale, y: start.y + b.2.y*scale), control: CGPoint(x: start.x + b.1.x*scale, y: start.y + b.1.y*scale))
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func drawPanelGlow(_ ctx: CGContext, rect: CGRect) {
    let glow = CGRect(x: rect.minX + 14, y: rect.maxY - 22, width: rect.width - 28, height: 8)
    drawGradient(ctx, glow, RGB(r: 0.98, g: 0.86, b: 0.68, a: 0.9), RGB(r: 0.90, g: 0.72, b: 0.45, a: 0.05))
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

let x0: CGFloat = 821
let yBottomImage: CGFloat = 725
let yTopImage: CGFloat = 175
let boxW: CGFloat = 333
let boxH: CGFloat = 550
let drawY = CGFloat(height) - yBottomImage
let boxRect = CGRect(x: x0, y: drawY, width: boxW, height: boxH)

let wallColor = avgColor(rep, CGRect(x: 1165, y: 340, width: 40, height: 180))
let frameColor = avgColor(rep, CGRect(x: 780, y: 260, width: 28, height: 220))
let marble = avgColor(rep, CGRect(x: 862, y: 226, width: 120, height: 180))

fill(ctx, boxRect, wallColor)

let leftGap: CGFloat = 18
let rightGap: CGFloat = 20
let topGap: CGFloat = 6
let bottomGap: CGFloat = 10
let innerRect = CGRect(x: boxRect.minX + leftGap, y: boxRect.minY + bottomGap, width: boxRect.width - leftGap - rightGap, height: boxRect.height - topGap - bottomGap)

let darkWood = RGB(r: 0.22, g: 0.22, b: 0.21)
let darkWood2 = RGB(r: 0.28, g: 0.28, b: 0.27)
let brass = RGB(r: 0.74, g: 0.61, b: 0.44)
let warmLight = RGB(r: 0.98, g: 0.86, b: 0.68)
let lightStoneTop = RGB(r: 0.20, g: 0.20, b: 0.19)
let lightStoneBottom = RGB(r: 0.14, g: 0.14, b: 0.13)

let upperH = innerRect.height * 0.45
let upperRect = CGRect(x: innerRect.minX, y: innerRect.maxY - upperH, width: innerRect.width, height: upperH)
let lowerRect = CGRect(x: innerRect.minX, y: innerRect.minY, width: innerRect.width, height: upperRect.minY - innerRect.minY)

let upperInset: CGFloat = 8
let upperPanel = CGRect(x: upperRect.minX + upperInset, y: upperRect.minY + 6, width: upperRect.width - upperInset*2, height: upperRect.height - 10)
let upperShelfY = upperPanel.minY + upperPanel.height * 0.40
let upperShelfH: CGFloat = 7

fill(ctx, upperRect, darkWood)
ctx.setAlpha(0.18)
fill(ctx, CGRect(x: upperRect.minX + upperRect.width*0.62, y: upperRect.minY, width: upperRect.width*0.38, height: upperRect.height), darkWood2)
ctx.setAlpha(1)

drawPanelGlow(ctx, rect: upperRect)
fill(ctx, CGRect(x: upperPanel.minX, y: upperShelfY, width: upperPanel.width, height: upperShelfH), brass)
ctx.setAlpha(0.35)
fill(ctx, CGRect(x: upperPanel.minX, y: upperShelfY - 2, width: upperPanel.width, height: 2), warmLight)
ctx.setAlpha(1)

let toyBaseY = upperShelfY + upperShelfH + 10
let toyColors = [RGB(r: 0.93, g: 0.83, b: 0.80), RGB(r: 0.86, g: 0.84, b: 0.92), RGB(r: 0.96, g: 0.80, b: 0.72)]
for i in 0..<3 {
    let cx = upperPanel.minX + 38 + CGFloat(i) * 24
    fill(ctx, CGRect(x: cx - 7, y: toyBaseY, width: 14, height: 18), toyColors[i])
    fill(ctx, CGRect(x: cx - 6, y: toyBaseY + 16, width: 12, height: 12), toyColors[i])
    fill(ctx, CGRect(x: cx - 9, y: toyBaseY + 24, width: 5, height: 5), toyColors[i])
    fill(ctx, CGRect(x: cx + 4, y: toyBaseY + 24, width: 5, height: 5), toyColors[i])
}

let bookBlock = CGRect(x: upperPanel.minX + upperPanel.width*0.40, y: toyBaseY + 4, width: 36, height: 44)
fill(ctx, bookBlock, RGB(r: 0.18, g: 0.25, b: 0.42))
stroke(ctx, bookBlock, RGB(r: 0.34, g: 0.43, b: 0.63), 1)
ctx.setStrokeColor(NSColor(calibratedWhite: 0.90, alpha: 0.9).cgColor)
ctx.setLineWidth(1)
ctx.stroke(CGRect(x: bookBlock.minX + 11, y: bookBlock.minY + 11, width: 14, height: 14))

let vaseX = upperPanel.maxX - 54
let vaseY = toyBaseY + 2
drawVase(ctx, center: CGPoint(x: vaseX, y: vaseY), scale: 1.0)
drawBranches(ctx, start: CGPoint(x: vaseX, y: vaseY + 22), scale: 1.0)

let dividerX = innerRect.minX + innerRect.width * 0.61
let leftLower = CGRect(x: lowerRect.minX, y: lowerRect.minY, width: dividerX - lowerRect.minX, height: lowerRect.height)
let rightLower = CGRect(x: dividerX, y: lowerRect.minY, width: lowerRect.maxX - dividerX, height: lowerRect.height)

fill(ctx, leftLower, darkWood2)
ctx.setAlpha(0.10)
for i in 0..<10 {
    let x = leftLower.minX + CGFloat(i) * (leftLower.width / 10)
    fill(ctx, CGRect(x: x, y: leftLower.minY, width: 1, height: leftLower.height), RGB(r: 0.45, g: 0.45, b: 0.44))
}
ctx.setAlpha(1)

let drawerH = leftLower.height * 0.26
let drawerRect = CGRect(x: leftLower.minX, y: leftLower.minY, width: leftLower.width, height: drawerH)
stroke(ctx, leftLower, RGB(r: 0.16, g: 0.16, b: 0.16), 1)
ctx.setStrokeColor(NSColor(calibratedWhite: 0.10, alpha: 0.6).cgColor)
ctx.setLineWidth(1)
ctx.move(to: CGPoint(x: leftLower.minX, y: drawerRect.maxY))
ctx.addLine(to: CGPoint(x: leftLower.maxX, y: drawerRect.maxY))
ctx.strokePath()

let handleY = drawerRect.midY
ctx.setStrokeColor(NSColor(calibratedWhite: 0.85, alpha: 0.9).cgColor)
ctx.setLineWidth(2)
ctx.move(to: CGPoint(x: drawerRect.midX - 18, y: handleY))
ctx.addLine(to: CGPoint(x: drawerRect.midX + 18, y: handleY))
ctx.strokePath()

let nicheMargin: CGFloat = 8
let nicheRect = CGRect(x: rightLower.minX + nicheMargin, y: rightLower.minY + nicheMargin, width: rightLower.width - nicheMargin*2, height: rightLower.height - nicheMargin*2)
fill(ctx, nicheRect, lightStoneTop)
drawGradient(ctx, nicheRect, lightStoneTop, lightStoneBottom)
drawPanelGlow(ctx, rect: nicheRect)

let topSlot = CGRect(x: nicheRect.minX + 10, y: nicheRect.maxY - 34, width: nicheRect.width - 20, height: 4)
fill(ctx, topSlot, RGB(r: 0.30, g: 0.30, b: 0.29))

let screenRect = CGRect(x: nicheRect.minX + 8, y: nicheRect.minY + nicheRect.height*0.38, width: nicheRect.width - 16, height: nicheRect.height*0.28)
fill(ctx, screenRect, RGB(r: 0.24, g: 0.24, b: 0.23))
ctx.setAlpha(0.35)
fill(ctx, CGRect(x: screenRect.minX, y: screenRect.minY, width: screenRect.width, height: screenRect.height*0.48), RGB(r: 0.40, g: 0.40, b: 0.38))
ctx.setAlpha(1)
stroke(ctx, screenRect, RGB(r: 0.34, g: 0.34, b: 0.32), 2)

ctx.setStrokeColor(NSColor(calibratedWhite: 0.97, alpha: 0.35).cgColor)
ctx.setLineWidth(3)
ctx.move(to: CGPoint(x: screenRect.minX + 12, y: screenRect.minY + 10))
ctx.addQuadCurve(to: CGPoint(x: screenRect.maxX - 14, y: screenRect.maxY - 18), control: CGPoint(x: screenRect.midX, y: screenRect.midY + 10))
ctx.strokePath()
ctx.move(to: CGPoint(x: screenRect.minX + 10, y: screenRect.maxY - 22))
ctx.addQuadCurve(to: CGPoint(x: screenRect.maxX - 16, y: screenRect.minY + 14), control: CGPoint(x: screenRect.midX - 10, y: screenRect.midY))
ctx.strokePath()

let rightShelfY = nicheRect.minY + nicheRect.height * 0.24
fill(ctx, CGRect(x: nicheRect.minX + 8, y: rightShelfY, width: nicheRect.width - 16, height: 6), RGB(r: 0.30, g: 0.30, b: 0.29))
let decorX = nicheRect.minX + 24
let decorY = rightShelfY + 12
fill(ctx, CGRect(x: decorX, y: decorY, width: 18, height: 18), RGB(r: 0.18, g: 0.18, b: 0.18))
stroke(ctx, CGRect(x: decorX+4, y: decorY+4, width: 10, height: 10), RGB(r: 0.75, g: 0.75, b: 0.75), 1)
drawBookStack(ctx, at: CGPoint(x: nicheRect.maxX - 54, y: decorY - 2), width: 36)

let nicheBottomPanel = CGRect(x: nicheRect.minX, y: nicheRect.minY, width: nicheRect.width, height: nicheRect.height * 0.18)
ctx.setAlpha(0.18)
fill(ctx, nicheBottomPanel, RGB(r: 0.26, g: 0.26, b: 0.25))
ctx.setAlpha(1)
stroke(ctx, nicheRect, RGB(r: 0.32, g: 0.32, b: 0.31), 1)

let slimDivider = CGRect(x: dividerX - 1, y: lowerRect.minY + 4, width: 2, height: lowerRect.height - 8)
fill(ctx, slimDivider, brass)

let sideCoverW: CGFloat = 14
fill(ctx, CGRect(x: boxRect.minX - 2, y: boxRect.minY, width: sideCoverW, height: boxRect.height), frameColor)
fill(ctx, CGRect(x: boxRect.maxX - sideCoverW + 2, y: boxRect.minY, width: sideCoverW, height: boxRect.height), wallColor)
fill(ctx, CGRect(x: boxRect.minX - 2, y: boxRect.maxY - 14, width: boxRect.width + 4, height: 14), wallColor)
fill(ctx, CGRect(x: boxRect.minX - 2, y: boxRect.minY, width: boxRect.width + 4, height: 14), wallColor)

canvas.unlockFocus()

guard let outTiff = canvas.tiffRepresentation,
      let outRep = NSBitmapImageRep(data: outTiff),
      let png = outRep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
