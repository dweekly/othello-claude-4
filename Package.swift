// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OthelloApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OthelloApp",
            targets: ["OthelloApp"]
        ),
    ],
    targets: [
        .target(
            name: "OthelloApp",
            path: "OthelloApp",
            exclude: ["Tests", "Documentation"]
        ),
        .testTarget(
            name: "OthelloAppTests",
            dependencies: ["OthelloApp"],
            path: "OthelloApp/Tests"
        ),
    ]
)