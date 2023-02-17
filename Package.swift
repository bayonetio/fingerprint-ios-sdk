// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
    name: "fingerprint-ios-sdk",
    products: [
        .library(
            name: "Fingerprint",
            targets: ["Fingerprint"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                "Fingerprint"
            ]),
        .target(
            name: "Fingerprint",
            dependencies: [],
            path: "Fingerprint"),
        .testTarget(
            name: "FingerprintTest",
            dependencies: ["Fingerprint"]),
    ]
)
