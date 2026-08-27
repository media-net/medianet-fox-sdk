// swift-tools-version: 5.9
// MediaNetFoxSDK — version 0.0.9
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
        .package(url: "https://github.com/media-net/MediaNetAdSDK-dist", exact: "0.4.9"),
        .package(url: "https://github.com/media-net/ios-packages", exact: "0.5.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", "12.3.0" ..< "13.0.0")
    ],
    targets: [
        .binaryTarget(
            name: "MediaNetFoxSDK",
            url: "https://github.com/media-net/medianet-fox-sdk/releases/download/0.0.9/MediaNetFoxSDK.xcframework.zip",
            checksum: "f680f92190b2461d7265b82e1e9cfdd6555a6cd16c3b31ef7b20655a37189ef9"
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
