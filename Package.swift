// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
    name: "BayonetFingerprint",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "BayonetFingerprint",
            targets: [
                "BayonetFingerprint",
            ]
        ),
        // .executable(
        //     name: "App",
        //     targets: [
        //         "App",
        //     ]
        // ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/fingerprintjs/fingerprintjs-pro-ios", from: "2.0.0"),
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "BayonetFingerprint",
            dependencies: [
                .product(name: "FingerprintPro", package: "fingerprintjs-pro-ios"),
            ],
            path: "BayonetFingerprint"),
        .testTarget(
            name: "BayonetFingerprintTest",
            dependencies: [
                "BayonetFingerprint",
                .product(name: "Swifter", package: "swifter")
            ]
        ),
        // .executableTarget(
        //     name: "App",
        //     dependencies: [
        //         "Fingerprint",
        //     ],
        //     path: "App/Sources"
        // )
    ]
)
