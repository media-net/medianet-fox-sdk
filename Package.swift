// swift-tools-version: 5.9
// MediaNetFoxSDK — version 0.0.8
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
            url: "https://github.com/media-net/medianet-fox-sdk/releases/download/0.0.8/MediaNetFoxSDK.xcframework.zip",
            checksum: "afa1e8fb344656419007a8edc9488a559554897cc9c27ce70d15dbfccfe5ca11"
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
