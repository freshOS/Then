// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Then",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Then", targets: ["Then"])
    ],
    targets: [
        .target(name: "Then", path: "Source"),
        .testTarget(name: "ThenTests", dependencies: ["Then"], path: "ThenTests")
    ]
)
