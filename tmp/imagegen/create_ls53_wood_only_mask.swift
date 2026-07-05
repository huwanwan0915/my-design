import AppKit
import Foundation

let width = 1536
let height = 1024
let image = NSImage(size: NSSize(width: width, height: height))
image.lockFocus()
NSColor.white.setFill()
NSRect(x: 0, y: 0, width: width, height: height).fill()
NSColor.clear.setFill()

func rect(_ x: CGFloat, _ yFromTop: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    NSRect(x: x, y: CGFloat(height) - yFromTop - h, width: w, height: h).fill()
}

rect(0, 235, 214, 165)
rect(0, 408, 214, 230)
rect(0, 235, 18, 403)
rect(200, 235, 18, 403)
rect(317, 175, 52, 220)
rect(318, 395, 53, 185)
rect(914, 174, 16, 465)
rect(1112, 174, 16, 465)
rect(914, 174, 214, 16)
rect(914, 286, 214, 12)
rect(914, 401, 214, 12)
rect(914, 515, 214, 12)
rect(914, 527, 214, 112)
rect(914, 527, 214, 6)
rect(1019, 527, 8, 112)

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Could not create PNG")
}
try png.write(to: URL(fileURLWithPath: "tmp/imagegen/ls53-wood-only-mask.png"))
