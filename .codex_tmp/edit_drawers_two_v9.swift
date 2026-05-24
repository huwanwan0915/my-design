import AppKit

let inputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample.png"
let outputPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v9.png"

let url = URL(fileURLWithPath: inputPath)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let rep = src.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load image")
}

// Drawer-face geometry in source image coordinates.
let x0 = 832
let x1 = 999
let oldSeam1Top = 584
let oldSeam2Top = 651
let seamH = 8
let newSeamTop = 617

func copyRows(from sourceTop: Int, to targetTop: Int, xStart: Int, xEnd: Int, height: Int) {
    for dy in 0..<height {
        let sy = sourceTop + dy
        let ty = targetTop + dy
        for x in xStart...xEnd {
            if let c = src.colorAt(x: x, y: sy) {
                rep.setColor(c, atX: x, y: ty)
            }
        }
    }
}

// Remove first old seam by replacing it with nearby top-drawer wood rows.
copyRows(from: 545, to: oldSeam1Top, xStart: x0, xEnd: x1, height: seamH)

// Remove second old seam only in visible wood areas, keeping the robot overlap untouched.
copyRows(from: 612, to: oldSeam2Top, xStart: x0, xEnd: 890, height: seamH)
copyRows(from: 612, to: oldSeam2Top, xStart: 960, xEnd: x1, height: seamH)

// Reuse the original first seam appearance as the new middle seam.
copyRows(from: oldSeam1Top, to: newSeamTop, xStart: x0, xEnd: x1, height: seamH)

guard let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode output")
}
try png.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
