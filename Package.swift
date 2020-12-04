// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TwitterApacheThrift",
    products: [
        .library(
            name: "TwitterApacheThrift",
            targets: [
                "TwitterApacheThrift"
            ]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TwitterApacheThrift",
            dependencies: []),
        .testTarget(
            name: "TwitterApacheThriftTests",
            dependencies: ["TwitterApacheThrift"])
    ]
)
