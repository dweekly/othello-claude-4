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
            name: "OthelloCore",
            targets: ["OthelloCore"]
        ),
        .executable(
            name: "OthelloApp",
            targets: ["OthelloApp"]
        ),
    ],
    targets: [
        .target(
            name: "OthelloCore",
            path: "OthelloApp",
            exclude: ["Tests", "Documentation", "App", "Views", "ViewModels"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "OthelloApp",
            dependencies: ["OthelloCore"],
            path: "OthelloApp",
            sources: ["App", "Views", "ViewModels"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "OthelloAppTests",
            dependencies: ["OthelloCore"],
            path: "OthelloApp/Tests"
        ),
    ]
)