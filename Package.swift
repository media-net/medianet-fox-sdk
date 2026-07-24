// swift-tools-version: 5.9
// MediaNetFoxSDK — version 0.0.7
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
        .package(url: "https://github.com/media-net/MediaNetAdSDK-dist", exact: "0.4.8"),
        .package(url: "https://github.com/media-net/ios-packages", exact: "0.5.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", "12.3.0" ..< "13.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "MediaNetFoxSDK",
            url: "https://github.com/media-net/medianet-fox-sdk/releases/download/0.0.7/MediaNetFoxSDK.xcframework.zip",
            checksum: "7e7ad440d04640e0c96de4ecdc0b10f7503cc51177c755d7ba7ea80c38c7fb4d"
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
