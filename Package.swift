// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EvolvSwiftSDK",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "EvolvSwiftSDK",
            targets: ["EvolvSwiftSDK"]),
    ],
    targets: [
        .target(
            name: "EvolvSwiftSDK",
            dependencies: [],
            path: "EvolvSwiftSDK/EvolvSwiftSDK/Sources",
            exclude: ["Utils/Logger", "Supporting Files/Info.plist"])
    ],
    swiftLanguageVersions: [.v5]
)
