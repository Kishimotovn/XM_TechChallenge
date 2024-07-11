// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let modules = [
    "AppRoot"
]

let package = Package(
    name: "xm-ios",
    platforms: [
        .iOS("17.0"),
        .macOS(.v13),
    ],
    products: modules.map {
        .library(name: $0, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        .target(
            name: "AppRoot",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "AppRootTests",
            dependencies: [
                "AppRoot"
            ]
        )
    ]
)
