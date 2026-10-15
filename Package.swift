// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DECpedia",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "DECpedia", targets: ["DECpedia"])],
    targets: [
        .target(name: "DECpediaCore"),
        .executableTarget(name: "DECpedia", dependencies: ["DECpediaCore"], resources: [.copy("Resources")]),
        .testTarget(name: "DECpediaCoreTests", dependencies: ["DECpediaCore"])
    ]
)
