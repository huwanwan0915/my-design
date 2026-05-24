import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_v12.png"

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

let x0 = 917
let x1 = 988
let y0 = 647
let y1 = 776
let deskTop = 719

func copyBlock(srcX: Int, srcY: Int, dstX: Int, dstY: Int, width: Int, height: Int) {
    for dy in 0..<height {
        for dx in 0..<width {
            if let c = src.colorAt(x: srcX + dx, y: srcY + dy) {
                rep.setColor(c, atX: dstX + dx, y: dstY + dy)
            }
        }
    }
}

// Upper part: replace mouse silhouette area with neighboring cabinet/wall texture from the right side.
copyBlock(srcX: 995, srcY: y0, dstX: x0, dstY: y0, width: x1 - x0, height: deskTop - y0)

// Restore the drawer seam through that area using pixels from the same seam at left side.
copyBlock(srcX: 860, srcY: 686, dstX: x0, dstY: 686, width: x1 - x0, height: 3)

// Lower part on the table: replace with the same tabletop strip from the left neighbor region.
copyBlock(srcX: 840, srcY: deskTop, dstX: x0, dstY: deskTop, width: x1 - x0, height: y1 - deskTop)

// Blend left and right borders by borrowing immediate neighbors, so the patch edge does not show as a hard cut.
for y in y0..<y1 {
    if let c = src.colorAt(x: x0 - 1, y: y) { rep.setColor(c, atX: x0, y: y) }
    if let c = src.colorAt(x: x1, y: y) { rep.setColor(c, atX: x1 - 1, y: y) }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
