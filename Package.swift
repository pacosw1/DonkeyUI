// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DonkeyUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DonkeyUI",
            targets: ["DonkeyUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/exyte/PopupView.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/ksemianov/WrappingHStack", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "DonkeyUI",
            dependencies: [
                .product(name: "WrappingHStack", package: "WrappingHStack", condition: .when(platforms: [.iOS])),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "PopupView", package: "PopupView", condition: .when(platforms: [.iOS])),
            ]),
        .testTarget(
            name: "DonkeyUITests",
            dependencies: ["DonkeyUI"]),
    ]
)
