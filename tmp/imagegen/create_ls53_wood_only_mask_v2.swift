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

// Left coffee/bar cabinet: only existing light wood veneer, avoid marble backsplash, wine rail, coffee machine.
rect(0, 236, 214, 80)       // upper wood back/panel
rect(0, 224, 16, 414)       // left side stile
rect(202, 224, 16, 414)     // right side stile
rect(0, 444, 214, 194)      // lower drawer fronts/base
rect(0, 224, 214, 14)       // top rail
rect(0, 628, 214, 12)       // bottom rail

// Narrow pendant/slatted feature wood and lower panel.
rect(318, 176, 51, 214)     // vertical slats
rect(318, 392, 53, 188)     // lower wood panel

// Right display cabinet: wood frame, shelf boards, and lower drawer fronts only; protect stone back and objects.
rect(914, 174, 16, 466)     // left stile
rect(1112, 174, 16, 466)    // right stile
rect(914, 174, 214, 14)     // top rail
rect(914, 284, 214, 12)     // shelf board 1
rect(914, 398, 214, 12)     // shelf board 2
rect(914, 514, 214, 12)     // shelf board 3
rect(914, 526, 214, 114)    // lower drawer fronts
rect(914, 526, 214, 5)      // top drawer reveal
rect(1019, 526, 8, 114)     // vertical drawer seam area

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Could not create PNG")
}
try png.write(to: URL(fileURLWithPath: "tmp/imagegen/ls53-wood-only-mask-v2.png"))
