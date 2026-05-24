import AppKit

let originalPath = "/Users/huwanwan/my-design/11客厅-新1_LR65_from_jpg_sample_两抽屉_v10.png"
let editedPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v1.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_from_jpg_sample_两抽屉_去老鼠_AI_v2_轮廓合成.png"

guard let originalImage = NSImage(contentsOfFile: originalPath),
      let originalTiff = originalImage.tiffRepresentation,
      let original = NSBitmapImageRep(data: originalTiff),
      let editedImage = NSImage(contentsOfFile: editedPath),
      let editedTiff = editedImage.tiffRepresentation,
      let edited = NSBitmapImageRep(data: editedTiff),
      let result = original.copy() as? NSBitmapImageRep else {
    fatalError("Unable to load images")
}

let width = min(original.pixelsWide, edited.pixelsWide)
let height = min(original.pixelsHigh, edited.pixelsHigh)

func membership(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
    func ellipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, soft: CGFloat = 0.22) -> CGFloat {
        let d = sqrt(pow((x - cx) / rx, 2) + pow((y - cy) / ry, 2))
        if d <= 1 - soft { return 1 }
        if d >= 1 { return 0 }
        return (1 - d) / soft
    }
    func capsule(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, r: CGFloat, soft: CGFloat = 0.35) -> CGFloat {
        let vx = x2 - x1, vy = y2 - y1
        let wx = x - x1, wy = y - y1
        let c = max(0, min(1, (wx * vx + wy * vy) / (vx * vx + vy * vy)))
        let px = x1 + c * vx, py = y1 + c * vy
        let d = sqrt(pow(x - px, 2) + pow(y - py, 2)) / r
        if d <= 1 - soft { return 1 }
        if d >= 1 { return 0 }
        return (1 - d) / soft
    }
    var v: CGFloat = 0
    v = max(v, ellipse(cx: 947, cy: 679, rx: 20, ry: 21)) // head
    v = max(v, ellipse(cx: 924, cy: 654, rx: 15, ry: 14)) // left ear
    v = max(v, ellipse(cx: 962, cy: 649, rx: 14, ry: 16)) // right ear
    v = max(v, ellipse(cx: 947, cy: 717, rx: 21, ry: 35)) // body
    v = max(v, capsule(x1: 927, y1: 700, x2: 911, y2: 733, r: 8)) // left arm
    v = max(v, capsule(x1: 967, y1: 700, x2: 988, y2: 727, r: 8)) // right arm
    v = max(v, capsule(x1: 936, y1: 745, x2: 927, y2: 780, r: 7)) // left leg
    v = max(v, capsule(x1: 958, y1: 745, x2: 972, y2: 779, r: 7)) // right leg
    v = max(v, ellipse(cx: 909, cy: 735, rx: 9, ry: 10)) // left hand
    v = max(v, ellipse(cx: 990, cy: 728, rx: 8, ry: 10)) // right hand
    return max(0, min(1, v))
}

func blend(_ a: NSColor, _ b: NSColor, t: CGFloat) -> NSColor {
    let aa = a.usingColorSpace(.deviceRGB) ?? a
    let bb = b.usingColorSpace(.deviceRGB) ?? b
    return NSColor(
        deviceRed: aa.redComponent * (1 - t) + bb.redComponent * t,
        green: aa.greenComponent * (1 - t) + bb.greenComponent * t,
        blue: aa.blueComponent * (1 - t) + bb.blueComponent * t,
        alpha: aa.alphaComponent * (1 - t) + bb.alphaComponent * t
    )
}

for y in 620..<790 {
    if y < 0 || y >= height { continue }
    for x in 890..<1005 {
        if x < 0 || x >= width { continue }
        let t = membership(CGFloat(x), CGFloat(y))
        if t > 0,
           let oc = original.colorAt(x: x, y: y),
           let ec = edited.colorAt(x: x, y: y) {
            result.setColor(blend(oc, ec, t: t), atX: x, y: y)
        }
    }
}

let data = result.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
