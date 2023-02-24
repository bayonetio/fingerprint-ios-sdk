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
        .package(url: "https://github.com/fingerprintjs/fingerprintjs-pro-ios", from: "2.0.0"),
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Fingerprint",
            dependencies: [
                .product(name: "FingerprintPro", package: "fingerprintjs-pro-ios"),
            ],
            path: "Fingerprint"),
        .testTarget(
            name: "FingerprintTest",
            dependencies: [
                "Fingerprint",
                .product(name: "Swifter", package: "swifter")
            ]),
        .executableTarget(
            name: "App",
            dependencies: [
                "Fingerprint"
            ]),
    ]
)
