// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ObservabilityKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        // Core module with data types and protocols
        .library(
            name: "ObservabilityCore",
            targets: ["ObservabilityCore"]
        ),

        // Networking module with WebSocket client
        .library(
            name: "ObservabilityNetworking",
            targets: ["ObservabilityNetworking"]
        ),

        // SwiftUI components for dashboards
        .library(
            name: "ObservabilityUI",
            targets: ["ObservabilityUI"]
        ),

        // Common utilities and extensions
        .library(
            name: "ObservabilityCommon",
            targets: ["ObservabilityCommon"]
        )
    ],
    dependencies: [
        // Modern async networking
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    ],
    targets: [
        // MARK: - Core Module
        .target(
            name: "ObservabilityCore",
            dependencies: [
                "ObservabilityCommon",
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Networking Module
        .target(
            name: "ObservabilityNetworking",
            dependencies: [
                "ObservabilityCore",
                "ObservabilityCommon",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // MARK: - UI Module
        .target(
            name: "ObservabilityUI",
            dependencies: [
                "ObservabilityCore",
                "ObservabilityCommon"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Common Utilities
        .target(
            name: "ObservabilityCommon",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "ObservabilityKitTests",
            dependencies: [
                "ObservabilityCore",
                "ObservabilityNetworking",
                "ObservabilityUI",
                "ObservabilityCommon"
            ]
        )
    ]
)
