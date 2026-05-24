import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_v13.png"

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

func copyBlock(srcX: Int, srcY: Int, dstX: Int, dstY: Int, width: Int, height: Int) {
    for dy in 0..<height {
        for dx in 0..<width {
            if let c = src.colorAt(x: srcX + dx, y: srcY + dy) {
                rep.setColor(c, atX: dstX + dx, y: dstY + dy)
            }
        }
    }
}

// Patch bounds covering the mouse figurine only.
let dstX0 = 914
let dstX1 = 976
let dstY0 = 648
let dstYDesk = 719
let dstY1 = 781
let patchW = dstX1 - dstX0

// Upper patch: copy same drawer-face area from the left, preserving wood grain and seam.
let srcUpperX = 846
copyBlock(srcX: srcUpperX, srcY: dstY0, dstX: dstX0, dstY: dstY0, width: patchW, height: dstYDesk - dstY0)

// Lower patch: copy clean tabletop area from the left.
let srcLowerX = 836
copyBlock(srcX: srcLowerX, srcY: dstYDesk, dstX: dstX0, dstY: dstYDesk, width: patchW, height: dstY1 - dstYDesk)

// Soften only the first and last destination columns with immediate neighbors to reduce hard copy edges.
for y in dstY0..<dstY1 {
    if let leftNeighbor = src.colorAt(x: dstX0 - 1, y: y) {
        rep.setColor(leftNeighbor, atX: dstX0, y: y)
    }
    if let rightNeighbor = src.colorAt(x: dstX1, y: y) {
        rep.setColor(rightNeighbor, atX: dstX1 - 1, y: y)
    }
}

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
