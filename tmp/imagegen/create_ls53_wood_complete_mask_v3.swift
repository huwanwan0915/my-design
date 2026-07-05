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

// Left coffee/bar unit: continuous wood carcass and drawer fields; keep stone backsplash/coffee machine area protected.
rect(0, 224, 218, 96)       // upper wood panel + top frame
rect(0, 224, 22, 420)       // left vertical frame
rect(198, 224, 22, 420)     // right vertical frame
rect(0, 430, 218, 214)      // lower wood drawer/door block including rails
rect(0, 620, 218, 24)       // bottom frame / plinth wood face

// Pendant feature: continuous slatted wood niche and lower panel.
rect(316, 172, 57, 414)

// Right display cabinet: broader continuous wood structure, shelves and lower fronts; stone back remains mostly protected.
rect(910, 170, 222, 22)     // top wood rail
rect(910, 170, 24, 474)     // left stile
rect(1108, 170, 24, 474)    // right stile
rect(910, 278, 222, 24)     // shelf board 1 incl. front edge
rect(910, 392, 222, 24)     // shelf board 2 incl. front edge
rect(910, 506, 222, 24)     // shelf board 3 incl. front edge
rect(910, 522, 222, 122)    // complete lower drawer/door block
rect(910, 636, 222, 10)     // lower rail/plinth

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Could not create PNG")
}
try png.write(to: URL(fileURLWithPath: "tmp/imagegen/ls53-wood-complete-mask-v3.png"))
