import AppKit
let width = 1536, height = 1024
let outputPath = "/Users/huwanwan/my-design/tmp/imagegen/remove-swan-third-shelf-precise-mask.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
func set(_ x:Int,_ y:Int,_ a:CGFloat){ rep.setColor(NSColor(deviceRed:1, green:1, blue:1, alpha:a), atX:x, y:y) }
for y in 0..<height { for x in 0..<width { set(x,y,1) } }
func clearRect(_ x0:Int,_ y0:Int,_ x1:Int,_ y1:Int){ for y in max(0,y0)..<min(height,y1){ for x in max(0,x0)..<min(width,x1){ set(x,y,0) } } }
func clearEllipse(_ cx:CGFloat,_ cy:CGFloat,_ rx:CGFloat,_ ry:CGFloat){ for y in max(0,Int(cy-ry-2))..<min(height,Int(cy+ry+2)){ for x in max(0,Int(cx-rx-2))..<min(width,Int(cx+rx+2)){ let dx=(CGFloat(x)-cx)/rx; let dy=(CGFloat(y)-cy)/ry; if dx*dx+dy*dy <= 1 { set(x,y,0) } } } }
func clearCapsule(_ x1:CGFloat,_ y1:CGFloat,_ x2:CGFloat,_ y2:CGFloat,_ r:CGFloat){ let vx=x2-x1, vy=y2-y1; for y in max(0,Int(min(y1,y2)-r-2))..<min(height,Int(max(y1,y2)+r+2)){ for x in max(0,Int(min(x1,x2)-r-2))..<min(width,Int(max(x1,x2)+r+2)){ let wx=CGFloat(x)-x1, wy=CGFloat(y)-y1; let t=max(0,min(1,(wx*vx+wy*vy)/(vx*vx+vy*vy))); let px=x1+t*vx, py=y1+t*vy; let dx=CGFloat(x)-px, dy=CGFloat(y)-py; if sqrt(dx*dx+dy*dy)<=r { set(x,y,0) } } } }
// Remove exactly swan display and its supporting third shelf board (under swan). Keep shelf above and books shelf below outside mask.
clearRect(815,382,1030,418)      // shelf board directly under swan display
clearRect(840,318,1022,382)      // main swan/stand area
clearEllipse(910,350,76,43)
clearEllipse(966,352,60,40)
clearCapsule(838,352,1018,352,9)
clearCapsule(842,348,875,372,8)
clearCapsule(1015,348,984,372,8)
clearCapsule(925,318,915,350,8)
clearCapsule(970,327,955,354,8)
let data = rep.representation(using:.png, properties:[:])!
try data.write(to:URL(fileURLWithPath:outputPath))
print(outputPath)
