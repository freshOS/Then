// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Then",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Then", targets: ["Then"])
    ],
    targets: [
        .target(name: "Then", path: "Sources", resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "ThenTests", dependencies: ["Then"])
    ]
)
