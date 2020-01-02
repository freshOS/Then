// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Then",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Then", targets: ["Then"])
    ],
    targets: [
        .target(name: "Then"),
        .testTarget(name: "ThenTests", dependencies: ["Then"])
    ]
)
