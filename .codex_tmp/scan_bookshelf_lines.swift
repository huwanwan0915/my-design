import AppKit

let path = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_AI_gpt-image-2-3x2-4k_v1.png"
guard let img = NSImage(contentsOfFile: path), let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { fatalError("load") }
let x0 = 812, x1 = 1028
let y0 = 130, y1 = 640
func lum(_ c: NSColor?) -> Double {
    guard let cc = c?.usingColorSpace(.deviceRGB) else { return 0 }
    return Double(0.2126*cc.redComponent + 0.7152*cc.greenComponent + 0.0722*cc.blueComponent)
}
var rows: [(Int, Double, Double)] = []
for y in y0..<y1 {
    var sum = 0.0
    var sum2 = 0.0
    var n = 0.0
    for x in x0..<x1 {
        let l = lum(rep.colorAt(x: x, y: y))
        sum += l; sum2 += l*l; n += 1
    }
    let avg = sum/n
    let varr = sum2/n - avg*avg
    rows.append((y, avg, varr))
}
for i in 2..<(rows.count-2) {
    let y = rows[i].0
    let avg = rows[i].1
    let varr = rows[i].2
    let grad = abs(rows[i+2].1 - rows[i-2].1)
    if grad > 0.020 || varr > 0.010 {
        print(String(format: "%4d avg %.3f var %.4f grad %.4f", y, avg, varr, grad))
    }
}
