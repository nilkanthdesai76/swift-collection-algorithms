// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-collection-algorithms",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "CollectionAlgorithms",
            targets: ["CollectionAlgorithms"]
        ),
    ],
    targets: [
        .target(
            name: "CollectionAlgorithms",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CollectionAlgorithmsTests",
            dependencies: ["CollectionAlgorithms"]
        ),
    ]
)
