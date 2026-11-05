// swift-tools-version: 5.9
// MediaNetFoxSDK — version 1.1.1
//
// Two-pin graph (repo split): MediaNetAdSDK from MediaNetAdSDK-dist, the
// AdSDK-flavor renderer from ios-packages (renderer-only from 0.5.0). Both
// pull OMSDK_Medianet from OMSDK-Medianet-dist — one shared OMID dylib.

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
        .package(url: "https://github.com/media-net/MediaNetAdSDK-dist", exact: "1.1.0"),
        .package(url: "https://github.com/media-net/ios-packages", exact: "1.1.1"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", "12.3.0" ..< "13.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "MediaNetFoxSDK",
            url: "https://github.com/media-net/medianet-fox-sdk/releases/download/1.1.1/MediaNetFoxSDK.xcframework.zip",
            checksum: "886ba3e55cc2fa35fccabdc35a4da90f619e9dda2800caa7b769cfb7a0a8b399"
        ),
        .target(
            name: "MediaNetFoxSDKDeps",
            dependencies: [
                .product(name: "MediaNetAdSDK", package: "medianetadsdk-dist"),
                .product(name: "MediaNetRendererAdSDK", package: "ios-packages"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "Sources/MediaNetFoxSDKDeps"
        )
    ]
)
