import AppKit
import ImageIO

// Crop the original atlas without changing its alpha channel or painted artwork.
// Usage: swift Scripts/prepare-game-sprites.swift atlas.png output-directory
let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil)!
let atlas = CGImageSourceCreateImageAtIndex(source, 0, nil)!
let entries: [(String, CGRect)] = [
    ("gear", CGRect(x: 15, y: 20, width: 240, height: 263)),
    ("lantern", CGRect(x: 282, y: 0, width: 210, height: 285)),
    ("courier", CGRect(x: 514, y: 0, width: 238, height: 285)),
    ("tree", CGRect(x: 770, y: 0, width: 260, height: 285)),
    ("seal", CGRect(x: 1035, y: 25, width: 249, height: 253)),
    ("blocks", CGRect(x: 1290, y: 25, width: 246, height: 253)),
    ("leverOff", CGRect(x: 0, y: 285, width: 250, height: 232)),
    ("leverOn", CGRect(x: 263, y: 285, width: 246, height: 232)),
    ("lampOff", CGRect(x: 525, y: 286, width: 223, height: 232)),
    ("lampOn", CGRect(x: 775, y: 286, width: 225, height: 232)),
    ("key", CGRect(x: 1015, y: 285, width: 255, height: 234)),
    ("closedGate", CGRect(x: 1280, y: 280, width: 256, height: 238)),
    ("openGate", CGRect(x: 0, y: 518, width: 259, height: 219)),
    ("parcel", CGRect(x: 264, y: 525, width: 252, height: 225)),
    ("scroll", CGRect(x: 520, y: 518, width: 250, height: 232)),
    ("crystal", CGRect(x: 780, y: 518, width: 225, height: 237)),
    ("bridge", CGRect(x: 1002, y: 532, width: 300, height: 218)),
    ("codeTile", CGRect(x: 1294, y: 530, width: 242, height: 219)),
    ("tower", CGRect(x: 10, y: 739, width: 245, height: 285)),
    ("wrench", CGRect(x: 260, y: 754, width: 253, height: 270)),
    ("gem", CGRect(x: 520, y: 747, width: 190, height: 277)),
    ("notebook", CGRect(x: 713, y: 751, width: 332, height: 273)),
    ("trophy", CGRect(x: 1045, y: 752, width: 245, height: 272)),
    ("compass", CGRect(x: 1290, y: 748, width: 246, height: 276))
]
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
for (name, rect) in entries {
    let image = atlas.cropping(to: rect)!
    let context = CGContext(data: nil, width: 256, height: 256, bitsPerComponent: 8,
                            bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.interpolationQuality = .high
    let scale = min(236 / CGFloat(image.width), 236 / CGFloat(image.height))
    let width = CGFloat(image.width) * scale, height = CGFloat(image.height) * scale
    context.draw(image, in: CGRect(x: (256 - width) / 2, y: (256 - height) / 2, width: width, height: height))
    let png = NSBitmapImageRep(cgImage: context.makeImage()!).representation(using: .png, properties: [:])!
    try png.write(to: outputURL.appendingPathComponent(name + ".png"))
}
print("Prepared \(entries.count) transparent sprites.")
