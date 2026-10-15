import AppKit
import Foundation

// Original code-drawn app icon. Run from the project root, then iconutil -c icns.
let destination = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Support/AppIcon.iconset"
try FileManager.default.createDirectory(atPath: destination, withIntermediateDirectories: true)
for size in [16,32,64,128,256,512,1024] {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let scale = CGFloat(size)/1024
    NSAffineTransform(scale: scale).concat()
    let bounds = NSRect(x: 76,y: 76,width: 872,height: 872)
    let shape = NSBezierPath(roundedRect: bounds, xRadius: 195,yRadius: 195)
    NSGradient(starting: NSColor(calibratedRed: 0.17,green: 0.44,blue: 0.39,alpha: 1), ending: NSColor(calibratedRed: 0.055,green: 0.22,blue: 0.20,alpha: 1))!.draw(in: shape, angle: -70)
    let spine = NSBezierPath(roundedRect: NSRect(x: 228,y: 232,width: 33,height: 560),xRadius: 12,yRadius: 12)
    NSColor(calibratedRed: 0.90,green: 0.77,blue: 0.46,alpha: 1).setFill();spine.fill()
    let text: NSString = "D"
    text.draw(at: NSPoint(x: 310,y: 227),withAttributes: [.font:NSFont(name: "Georgia",size: 490)!, .foregroundColor:NSColor(calibratedWhite: 0.97,alpha: 1)])
    let line=NSBezierPath();line.move(to:NSPoint(x:315,y:235));line.line(to:NSPoint(x:750,y:235));line.lineWidth=8
    NSColor(calibratedWhite: 1,alpha:0.35).setStroke();line.stroke()
    NSGraphicsContext.restoreGraphicsState()
    let names: [String]
    switch size {
    case 16:names=["icon_16x16.png"]
    case 32:names=["icon_16x16@2x.png","icon_32x32.png"]
    case 64:names=["icon_32x32@2x.png"]
    case 128:names=["icon_128x128.png"]
    case 256:names=["icon_128x128@2x.png","icon_256x256.png"]
    case 512:names=["icon_256x256@2x.png","icon_512x512.png"]
    default:names=["icon_512x512@2x.png"]
    }
    for name in names { try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: destination).appendingPathComponent(name)) }
}
extension NSAffineTransform {
    convenience init(scale: CGFloat) { self.init(); self.scale(by: scale) }
}
