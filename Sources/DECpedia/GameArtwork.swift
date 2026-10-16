import SwiftUI

enum GameArtwork: String, CaseIterable {
    case gear, lantern, courier, tree, seal, blocks
    case leverOff, leverOn, lampOff, lampOn, key, closedGate
    case openGate, parcel, scroll, crystal, bridge, codeTile
    case tower, wrench, gem, notebook, trophy, compass

    static func theme(_ gameID: String) -> GameArtwork {
        switch gameID {
        case "algebra": return .gear
        case "classic": return .lantern
        case "public": return .courier
        case "curves": return .tree
        case "signatures": return .seal
        case "factoring": return .blocks
        case "linear": return .leverOn
        case "families": return .tower
        case "proof-geometry": return .scroll
        case "proof-analysis": return .compass
        default: return .notebook
        }
    }

    static func token(_ id: String) -> GameArtwork {
        let id = id.lowercased()
        if id.contains("key") || id.contains("cipher") || id.contains("bob") || id.contains("alice") { return .key }
        if id.contains("sign") || id.contains("seal") || id.contains("verified") { return .seal }
        if id.contains("plain") || id.contains("message") || id.contains("deliver") { return .parcel }
        return .scroll
    }

    // Load each raster only once. SwiftUI redraws and game moves reuse the images.
    private static let images: [GameArtwork: NSImage] = {
        #if SWIFT_PACKAGE
        let root = Bundle.module.resourceURL
        #else
        let root = Bundle.main.resourceURL
        #endif
        var images: [GameArtwork: NSImage] = [:]
        for item in allCases {
            if let url = root?.appendingPathComponent("Resources/GameSprites/" + item.rawValue + ".png"),
               let image = NSImage(contentsOf: url) {
                image.isTemplate = false
                images[item] = image
            }
        }
        return images
    }()

    var image: NSImage { Self.images[self] ?? NSImage(size: NSSize(width: 256, height: 256)) }
}

struct GameSprite: View {
    let artwork: GameArtwork
    var size: CGFloat = 48
    init(_ artwork: GameArtwork, size: CGFloat = 48) { self.artwork = artwork; self.size = size }
    var body: some View {
        Image(nsImage: artwork.image).resizable().interpolation(.high).scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

struct GameObjectLabel: View {
    let title: String
    let artwork: GameArtwork
    var size: CGFloat = 30
    init(_ title: String, artwork: GameArtwork, size: CGFloat = 30) {
        self.title = title; self.artwork = artwork; self.size = size
    }
    var body: some View {
        HStack(spacing: 9) { GameSprite(artwork, size: size); Text(title) }
    }
}
