<!-- Created by Ahmed Ragab Issa. -->

# MediaNetFoxSDK

A Fox-shaped iOS ad SDK for vertical-video (Shorts-style) feeds. Content slides
are interleaved with ads, prefetched against the next slot, and rendered in a
container with a built-in skip header. It layers on top of
[`MediaNetAdSDK`](https://github.com/media-net/ios-packages) (the Prebid wrapper)
plus the AdSDK-flavor `MediaNetRendererAdSDK` (Media.net's custom renderer).

This is the iOS counterpart of the Android `MediaNetFoxSDK`.

## Structure

```
MediaNetFoxSDK/
├── Package.swift                 # standalone package (consumes published deps)
├── Classes/
│   ├── MediaNetFoxSDK.swift      # public entry point (configure/isAd/getAd/session)
│   ├── Public/                   # AdError, AdFinishReason, AdLoadState, FoxErrors
│   ├── Config/                   # FoxOtaConfig (parser) + FoxConfigApi (EMS fetch)
│   ├── Views/                    # FoxBannerView + SkipHeaderView
│   └── Internal/                 # FoxScheduler + FoxDependencies (DI seams)
└── README.md
```

## Dependencies

- `MediaNetAdSDK` `~> 0.4` (provides `BannerAdView`, the renderer bridge, `MediaNetAdEvent`/`MediaNetPluginEventDelegate`).
- `MediaNetRendererAdSDK` `~> 0.0.20` (the `MNR_ADSDK_FLAVOR` renderer; registers via `MediaNetAdSDKClient`).
- `GoogleMobileAds` `12.x` (GAM event handler / ad sizes) — comes in transitively.
- A single shared `OMSDK_Medianet` (Open Measurement) across the graph.

## Versioning

- Current: `0.0.1` (pre-release).
- Lockstepped with `MediaNetAdSDK`: a FoxSDK release targets a compatible wrapper version (today `0.4.x`). Source lives in the wrapper repo; published from the dedicated `medianet-fox-sdk` consumer repo (SPM) and CocoaPods Trunk.

## Environment / constraints

- iOS 16+ (above the renderer's iOS 14 floor and Combine's iOS 13; pinned for headroom).
- Swift 5.9+, Xcode 15+.
- All public callbacks are delivered on the **main thread**; the SDK confines its mutable state to the main queue.
- `getAd(for:)` uses Combine.

## Installation

Swift Package Manager:
```swift
.package(url: "https://github.com/media-net/medianet-fox-sdk.git", from: "0.0.1")
```
CocoaPods:
```ruby
pod 'MediaNetFoxSDK'
```
`MediaNetAdSDK`, `MediaNetRendererAdSDK`, and `GoogleMobileAds` resolve transitively (all on public Trunk / SPM).

## iOS platform setup (host app)

These are host-app responsibilities the SDK cannot inject:
- **`GADApplicationIdentifier`** in your Info.plist — required; GMA (started in `configure`) fatal-errors without it.
- **`SKAdNetworkItems`** — add the union of Google + Media.net demand-partner identifiers (broken install attribution / lost demand otherwise).
- **ATT** — add `NSUserTrackingUsageDescription` and call `ATTrackingManager.requestTrackingAuthorization` at an appropriate moment (IDFA is zeroed otherwise). FoxSDK does not force the prompt.

## How to use

```swift
import MediaNetFoxSDK

// 1. Initialize once at launch.
MediaNetFoxSDKClient.shared.configure(accountID: "ACCOUNT_ID",
                                bundleIdentifier: Bundle.main.bundleIdentifier ?? "") { status, error in
    // status == .succeeded → ready; isAd/getAd are safe to call.
}

// 2. Build the feed (after configure completes).
let isAdSlot = try MediaNetFoxSDKClient.shared.isAd(at: position)   // throws FoxNotInitializedError before init

// 3. Fill an ad slot.
cancellable = MediaNetFoxSDKClient.shared.getAd(for: position).sink { state in
    switch state {
    case .inProgress: showSpinner()
    case .success(let foxView):
        foxView.presentingViewController = self
        foxView.didDisplayAd  = { /* on screen; skip countdown started */ }
        foxView.didReceiveClick = { /* tapped */ }
        foxView.didFinish     = { reason in advanceFeed() }   // .skipped / .completed
        attach(foxView)
    case .error:
        skipSlot()
    }
}
// cancel in prepareForReuse — a cancel before .success returns the ad to the warm slot.

// 4. Session + slide signals.
MediaNetFoxSDKClient.shared.userDidOpenShorts()
MediaNetFoxSDKClient.shared.userDidChangeSlot(at: index, forward: true)
MediaNetFoxSDKClient.shared.userDidLeaveShorts()
```

## References / docs

- Integration guide: `docs/ads-sdk/ios/integration-guides/medianet-foxsdk.md` (docs repo).
- Android parity: `MediaNetFoxSDK` (Android wrapper repo).
- Publisher events: `docs/publisher-events-ios.md`.

## Design decisions

- **Deferred success** for `getAd(for:)` (publisher emits `.success` only after load; replays a warm view's loaded state on subscribe).
- **Not idempotent**: each `getAd` call yields the next ad in rotation; `position` is informational.
- **Depth-1 warm pool**, single-owner state machine; cancel-before-terminal returns the in-flight ad to the warm slot.
- **Closures** (not a delegate) per the API spec; `AdError`/`AdFinishReason` value types.
- **`didDisplayAd` + skip countdown** are sourced from the `MediaNetAdEvent.adRendered` plugin event; `.completed` from `adComplete` (Prebid-won outstream video only).
- **ARC `deinit`** teardown; no public `destroy()`.
- `configure` callback param is named `completion:` (idiomatic Swift; the spec's `sdkInitListener` name was not adopted).

## TODOs / known gaps

- `.completed` and `didDisplayAd` depend on the renderer publisher-event channel (shipped in `MediaNetAdSDK 0.4.0` / `MediaNetRendererAdSDK 0.0.20`); runtime smoke test recommended.
- Interstitial publisher events are blocked upstream (`InterstitialRenderingAdUnit` has no `setPluginEventDelegate`).
- `FoxConfigApi` uses `URLSession` directly (FoxSDK can't reuse the wrapper's internal `APIClient`); verify EMS response decoding against live headers.
- `PrivacyInfo.xcprivacy` + signing (cross-framework) tracked separately; OTA retry/offline, accessibility, and localization deferred.
- Example app and full unit-test suite are pending.
