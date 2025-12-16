// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BodyBuddyCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BodyBuddyCore",
            targets: ["BodyBuddyCore"]
        )
    ],
    targets: [
        .target(
            name: "BodyBuddyCore",
            path: "Sources/BodyBuddyCore"
        ),
        .testTarget(
            name: "BodyBuddyCoreTests",
            dependencies: ["BodyBuddyCore"],
            path: "Tests/BodyBuddyCoreTests"
        )
    ]
)
