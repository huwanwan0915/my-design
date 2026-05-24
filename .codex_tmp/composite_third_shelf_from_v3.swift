import AppKit

let basePath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_AI_gpt-image-2-3x2-4k_v1.png"
let aiPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_只去第三层板和摆件_AI_v3.png"
let outputPath = "/Users/huwanwan/my-design/output/imagegen/11客厅-新1_LR65_右侧门板LR65_只去第三层板和摆件_AI_v4_目标区合成.png"

guard let baseImage = NSImage(contentsOfFile: basePath),
      let baseTiff = baseImage.tiffRepresentation,
      let base = NSBitmapImageRep(data: baseTiff),
      let aiImage = NSImage(contentsOfFile: aiPath),
      let aiTiff = aiImage.tiffRepresentation,
      let ai = NSBitmapImageRep(data: aiTiff),
      let result = base.copy() as? NSBitmapImageRep else { fatalError("load") }

let width = min(base.pixelsWide, ai.pixelsWide)
let height = min(base.pixelsHigh, ai.pixelsHigh)
func clamp(_ v: CGFloat) -> CGFloat { max(0, min(1, v)) }
func smoothstep(_ e0: CGFloat, _ e1: CGFloat, _ x: CGFloat) -> CGFloat { let t = clamp((x-e0)/(e1-e0)); return t*t*(3-2*t) }
func rect(_ x: CGFloat, _ y: CGFloat, _ x0: CGFloat, _ y0: CGFloat, _ x1: CGFloat, _ y1: CGFloat, _ f: CGFloat) -> CGFloat {
    min(min(smoothstep(x0,x0+f,x), 1-smoothstep(x1-f,x1,x)), min(smoothstep(y0,y0+f,y), 1-smoothstep(y1-f,y1,y)))
}
func ellipse(_ x: CGFloat, _ y: CGFloat, _ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ soft: CGFloat) -> CGFloat {
    let d = sqrt(pow((x-cx)/rx,2)+pow((y-cy)/ry,2)); if d <= 1-soft { return 1 }; if d >= 1 { return 0 }; return (1-d)/soft
}
func capsule(_ x: CGFloat, _ y: CGFloat, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ r: CGFloat, _ soft: CGFloat) -> CGFloat {
    let vx=x2-x1, vy=y2-y1, wx=x-x1, wy=y-y1
    let t=clamp((wx*vx+wy*vy)/(vx*vx+vy*vy)); let px=x1+t*vx, py=y1+t*vy
    let d=sqrt(pow(x-px,2)+pow(y-py,2))/r; if d <= 1-soft { return 1 }; if d >= 1 { return 0 }; return (1-d)/soft
}
func mask(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
    var m: CGFloat = 0
    // Only swan decor and the shelf board directly below it. Do not touch the shelf above or books shelf below.
    m=max(m, rect(x,y,810,385,1032,418,7))
    m=max(m, ellipse(x,y,910,350,76,43,0.22))
    m=max(m, ellipse(x,y,966,352,60,40,0.22))
    m=max(m, rect(x,y,852,322,1008,382,8))
    m=max(m, capsule(x,y,840,352,1015,352,9,0.35))
    m=max(m, capsule(x,y,842,348,875,372,8,0.35))
    m=max(m, capsule(x,y,1015,348,984,372,8,0.35))
    m=max(m, capsule(x,y,925,318,915,350,8,0.35))
    m=max(m, capsule(x,y,970,327,955,354,8,0.35))
    return clamp(m)
}
func blend(_ a: NSColor, _ b: NSColor, _ t: CGFloat) -> NSColor {
    let aa=a.usingColorSpace(.deviceRGB) ?? a, bb=b.usingColorSpace(.deviceRGB) ?? b
    return NSColor(deviceRed: aa.redComponent*(1-t)+bb.redComponent*t, green: aa.greenComponent*(1-t)+bb.greenComponent*t, blue: aa.blueComponent*(1-t)+bb.blueComponent*t, alpha: aa.alphaComponent*(1-t)+bb.alphaComponent*t)
}
for y in 300..<423 where y >= 0 && y < height {
    for x in 805..<1038 where x >= 0 && x < width {
        let m = mask(CGFloat(x), CGFloat(y))
        if m > 0, let bc=base.colorAt(x:x,y:y), let ac=ai.colorAt(x:x,y:y) { result.setColor(blend(bc,ac,m), atX:x, y:y) }
    }
}
let data=result.representation(using:.png, properties:[:])!
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
