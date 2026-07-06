// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Aspects",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Aspects",
            targets: ["Aspects"]
        ),
    ],
    targets: [
        .target(
            name: "Aspects",
            path: "Aspects",
            exclude: [".DS_Store"],
            sources: ["Aspects.m"],
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "AspectsSwiftTests",
            dependencies: ["Aspects"],
            path: "Tests/AspectsSwiftTests"
        ),
    ]
)
