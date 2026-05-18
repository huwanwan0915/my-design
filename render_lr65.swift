import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let inputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "11客厅-新1.jpg"
let outputPath = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "客厅餐边柜和书架LR65.png"

func loadImage(at path: String) -> CGImage? {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
}

func savePNG(_ image: CGImage, to path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        return false
    }
    CGImageDestinationAddImage(dest, image, nil)
    return CGImageDestinationFinalize(dest)
}

guard let cgImage = loadImage(at: inputPath) else {
    fputs("Failed to load input image\n", stderr)
    exit(1)
}

let width = cgImage.width
let height = cgImage.height
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fputs("Failed to create context\n", stderr)
    exit(1)
}

ctx.interpolationQuality = .high
ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

struct Region {
    let rect: CGRect
    let orientation: Orientation
}

enum Orientation {
    case horizontal
    case vertical
    case diagonal
}

let regions: [Region] = [
    .init(rect: CGRect(x: 0, y: 185, width: 420, height: 140), orientation: .horizontal),
    .init(rect: CGRect(x: 0, y: 406, width: 420, height: 250), orientation: .horizontal),
    .init(rect: CGRect(x: 712, y: 138, width: 98, height: 465), orientation: .vertical),
    .init(rect: CGRect(x: 1549, y: 138, width: 442, height: 497), orientation: .horizontal)
]

func oakTintColor() -> CGColor {
    return CGColor(red: 0.76, green: 0.66, blue: 0.56, alpha: 1.0)
}

func darkerOakColor() -> CGColor {
    return CGColor(red: 0.64, green: 0.53, blue: 0.44, alpha: 0.32)
}

func lighterOakColor() -> CGColor {
    return CGColor(red: 0.87, green: 0.79, blue: 0.70, alpha: 0.22)
}

func applyTintAndGrain(region: Region, index: Int) {
    ctx.saveGState()
    ctx.clip(to: region.rect)

    // Keep the original shading, but pull the hue toward LR65's warm beige oak.
    ctx.setBlendMode(.multiply)
    ctx.setAlpha(0.42)
    ctx.setFillColor(oakTintColor())
    ctx.fill(region.rect)

    ctx.setBlendMode(.softLight)
    ctx.setAlpha(0.18)
    ctx.setFillColor(lighterOakColor())
    ctx.fill(region.rect)

    ctx.setBlendMode(.multiply)
    ctx.setAlpha(0.18)
    ctx.setFillColor(darkerOakColor())
    ctx.fill(region.rect)

    // Fine straight-grain overlay.
    ctx.setBlendMode(.normal)
    ctx.setShouldAntialias(true)

    let rect = region.rect
    let minX = Int(rect.minX.rounded(.down))
    let maxX = Int(rect.maxX.rounded(.up))
    let minY = Int(rect.minY.rounded(.down))
    let maxY = Int(rect.maxY.rounded(.up))

    var seed = UInt64(0x9E3779B97F4A7C15 &+ UInt64(index) &* 0x1000003D)
    func next() -> CGFloat {
        seed &+= 0x9E3779B97F4A7C15
        var z = seed
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return CGFloat(z & 0xffff) / CGFloat(0xffff)
    }

    let grainColor = CGColor(red: 0.54, green: 0.43, blue: 0.33, alpha: 0.10)
    ctx.setStrokeColor(grainColor)

    switch region.orientation {
    case .horizontal:
        ctx.setLineWidth(1.0)
        var y = minY
        while y < maxY {
            let spacing = 4 + Int(next() * 7)
            let wobble = CGFloat(next() * 2.0 - 1.0)
            let y1 = CGFloat(y) + wobble
            let alpha = 0.05 + next() * 0.09
            ctx.setStrokeColor(CGColor(red: 0.48, green: 0.37, blue: 0.28, alpha: alpha))
            ctx.beginPath()
            ctx.move(to: CGPoint(x: CGFloat(minX), y: y1))
            ctx.addLine(to: CGPoint(x: CGFloat(maxX), y: y1 + CGFloat(next() * 0.8 - 0.4)))
            ctx.strokePath()
            y += spacing
        }
    case .vertical:
        ctx.setLineWidth(1.0)
        var x = minX
        while x < maxX {
            let spacing = 4 + Int(next() * 6)
            let wobble = CGFloat(next() * 2.0 - 1.0)
            let x1 = CGFloat(x) + wobble
            let alpha = 0.05 + next() * 0.09
            ctx.setStrokeColor(CGColor(red: 0.48, green: 0.37, blue: 0.28, alpha: alpha))
            ctx.beginPath()
            ctx.move(to: CGPoint(x: x1, y: CGFloat(minY)))
            ctx.addLine(to: CGPoint(x: x1 + CGFloat(next() * 0.8 - 0.4), y: CGFloat(maxY)))
            ctx.strokePath()
            x += spacing
        }
    case .diagonal:
        ctx.setLineWidth(1.0)
        var t = 0
        while t < Int(rect.width + rect.height) {
            let spacing = 8 + Int(next() * 8)
            let alpha = 0.03 + next() * 0.06
            ctx.setStrokeColor(CGColor(red: 0.48, green: 0.37, blue: 0.28, alpha: alpha))
            ctx.beginPath()
            let x = CGFloat(minX) + CGFloat(t)
            ctx.move(to: CGPoint(x: x, y: CGFloat(minY)))
            ctx.addLine(to: CGPoint(x: x + 40, y: CGFloat(maxY)))
            ctx.strokePath()
            t += spacing
        }
    }

    ctx.restoreGState()
}

for (index, region) in regions.enumerated() {
    applyTintAndGrain(region: region, index: index)
}

guard let result = ctx.makeImage() else {
    fputs("Failed to render output image\n", stderr)
    exit(1)
}

guard savePNG(result, to: outputPath) else {
    fputs("Failed to save PNG\n", stderr)
    exit(1)
}

print(outputPath)
