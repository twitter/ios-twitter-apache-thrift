// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0

import PackageDescription

let package = Package(
    name: "TwitterApacheThrift",
    platforms: [
        .iOS("13.4"),
        .macOS("10.15.4")
    ],
    products: [
        .library(
            name: "TwitterApacheThrift",
            type: .dynamic,
            targets: [
                "TwitterApacheThrift"
            ]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TwitterApacheThrift",
            dependencies: []
        ),
        .testTarget(
            name: "TwitterApacheThriftTests",
            dependencies: [
                "TwitterApacheThrift"
            ],
            exclude:[
                "Fixture.thrift"
            ]
        )
    ]
)
