// swift-tools-version: 5.9
//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
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
        .library(
            name: "OthelloUI",
            targets: ["OthelloUI"]
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
        .target(
            name: "OthelloUI",
            dependencies: ["OthelloCore"],
            path: "OthelloApp",
            sources: ["Views", "ViewModels"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "OthelloApp",
            dependencies: ["OthelloCore", "OthelloUI"],
            path: "OthelloApp",
            sources: ["App"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "OthelloAppTests",
            dependencies: ["OthelloCore", "OthelloUI"],
            path: "OthelloApp/Tests"
        ),
    ]
)