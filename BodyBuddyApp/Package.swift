// swift-tools-version: 5.9
// Package.swift for BodyBuddyApp (used for development/testing)
// Note: For iOS app distribution, use the Xcode project

import PackageDescription

let package = Package(
    name: "BodyBuddyApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BodyBuddyApp",
            targets: ["BodyBuddyApp"]
        )
    ],
    dependencies: [
        .package(path: "../BodyBuddyCore")
    ],
    targets: [
        .target(
            name: "BodyBuddyApp",
            dependencies: ["BodyBuddyCore"],
            path: "Sources"
        )
    ]
)
