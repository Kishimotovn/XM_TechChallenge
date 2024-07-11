// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let modules = [
    "AppRoot",
    "APIClient",
    "ConfigConstant",
    "QuestionFeed",
    "Models",
    "XCTestDebugSupport"
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
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.9.0")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
    ],
    targets: [
        .target(
            name: "AppRoot",
            dependencies: [
                "APIClient",
                "QuestionFeed",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                "ConfigConstant",
                "Models",
                "XCTestDebugSupport",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ConfigConstant",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "QuestionFeed",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models"
        ),
        .testTarget(
            name: "AppRootTests",
            dependencies: [
                "AppRoot",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "APIClientTests",
            dependencies: [
                "APIClient"
            ]
        ),
        .target(name: "XCTestDebugSupport")
    ]
)
