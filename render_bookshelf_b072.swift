import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let inputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "客厅餐边柜和书架LR65.png"
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

struct PanelRegion {
    let rect: CGRect
}

let sidePanels: [PanelRegion] = [
    .init(rect: CGRect(x: 1548, y: 138, width: 36, height: 1390)),
    .init(rect: CGRect(x: 1948, y: 138, width: 36, height: 1390))
]

func fillB072(panel: PanelRegion, seedOffset: UInt64) {
    ctx.saveGState()
    ctx.clip(to: panel.rect)

    // Neutralize the oak while keeping original light/shadow.
    ctx.setBlendMode(.color)
    ctx.setAlpha(0.82)
    ctx.setFillColor(CGColor(red: 0.79, green: 0.77, blue: 0.74, alpha: 1.0))
    ctx.fill(panel.rect)

    ctx.setBlendMode(.screen)
    ctx.setAlpha(0.10)
    ctx.setFillColor(CGColor(red: 0.88, green: 0.86, blue: 0.83, alpha: 1.0))
    ctx.fill(panel.rect)

    ctx.setBlendMode(.multiply)
    ctx.setAlpha(0.10)
    ctx.setFillColor(CGColor(red: 0.66, green: 0.63, blue: 0.60, alpha: 1.0))
    ctx.fill(panel.rect)

    // Very subtle plain-matte texture, not wood grain.
    var seed = seedOffset
    func next() -> CGFloat {
        seed &+= 0x9E3779B97F4A7C15
        var z = seed
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return CGFloat(z & 0xffff) / CGFloat(0xffff)
    }

    let minY = Int(panel.rect.minY.rounded(.down))
    let maxY = Int(panel.rect.maxY.rounded(.up))
    let minX = Int(panel.rect.minX.rounded(.down))
    let maxX = Int(panel.rect.maxX.rounded(.up))

    ctx.setBlendMode(.softLight)
    ctx.setLineWidth(1.0)
    var y = minY
    while y < maxY {
        let alpha = 0.015 + next() * 0.02
        let shade = 0.70 + next() * 0.12
        ctx.setStrokeColor(CGColor(red: shade, green: shade, blue: shade - 0.01, alpha: alpha))
        ctx.beginPath()
        ctx.move(to: CGPoint(x: CGFloat(minX), y: CGFloat(y)))
        ctx.addLine(to: CGPoint(x: CGFloat(maxX), y: CGFloat(y)))
        ctx.strokePath()
        y += 6 + Int(next() * 10)
    }

    // Crisp front edges so the side boards read as separate B072 panels.
    ctx.setBlendMode(.multiply)
    ctx.setLineWidth(1.0)
    ctx.setStrokeColor(CGColor(red: 0.58, green: 0.55, blue: 0.52, alpha: 0.18))
    ctx.stroke(panel.rect.insetBy(dx: 0.5, dy: 0.5))

    ctx.restoreGState()
}

for (index, panel) in sidePanels.enumerated() {
    fillB072(panel: panel, seedOffset: UInt64(index + 1) * 0x1000003D)
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
