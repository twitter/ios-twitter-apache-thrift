// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0

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
