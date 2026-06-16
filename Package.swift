// swift-tools-version: 5.9
// MediaNetFoxSDK — version 0.0.3

import PackageDescription

let package = Package(
    name: "MediaNetFoxSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MediaNetFoxSDK",
            targets: ["MediaNetFoxSDK", "MediaNetFoxSDKDeps"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/media-net/ios-packages", from: "0.4.2"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", "12.3.0" ..< "13.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "MediaNetFoxSDK",
            url: "https://github.com/media-net/medianet-fox-sdk/releases/download/0.0.3/MediaNetFoxSDK.xcframework.zip",
            checksum: "47ab5700e64f6d7abf420b02a912b91fe863c7d1796debbb5af6cc2cfc3aa940"
        ),
        .target(
            name: "MediaNetFoxSDKDeps",
            dependencies: [
                .product(name: "MediaNetAdSDK", package: "ios-packages"),
                .product(name: "MediaNetRendererAdSDK", package: "ios-packages"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "Sources/MediaNetFoxSDKDeps"
        )
    ]
)
