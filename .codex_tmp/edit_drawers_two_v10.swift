import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

// Final verified drawer-face span in image coordinates.
let x0 = 837
let x1 = 1027
let oldSeam1 = 585
let oldSeam2 = 652
let newSeam = 619
let bandH = 6

func copyRows(sourceTop: Int, targetTop: Int, xStart: Int, xEnd: Int, height: Int) {
    for dy in 0..<height {
        for x in xStart...xEnd {
            if let c = src.colorAt(x: x, y: sourceTop + dy) {
                rep.setColor(c, atX: x, y: targetTop + dy)
            }
        }
    }
}

// 1) remove upper old seam by copying nearby clean upper-drawer wood
copyRows(sourceTop: 545, targetTop: oldSeam1 - 1, xStart: x0, xEnd: x1, height: bandH)

// 2) create the new middle seam using the original upper seam look
copyRows(sourceTop: oldSeam1 - 1, targetTop: newSeam - 1, xStart: x0, xEnd: x1, height: bandH)

// 3) remove lower old seam only where drawer face is visible, keep robot overlap untouched
copyRows(sourceTop: 612, targetTop: oldSeam2 - 1, xStart: x0, xEnd: 905, height: bandH)
copyRows(sourceTop: 612, targetTop: oldSeam2 - 1, xStart: 972, xEnd: x1, height: bandH)

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
