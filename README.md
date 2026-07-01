<!-- Created by Ahmed Ragab Issa. -->

# MediaNetFoxSDK

A Fox-shaped iOS ad SDK for vertical-video (Shorts-style) feeds. Content slides
are interleaved with ads, prefetched against the next slot, and rendered in a
container with a built-in skip header. It layers on top of
[`MediaNetAdSDK`](https://github.com/media-net/ios-packages) (the Prebid wrapper)
plus the AdSDK-flavor `MediaNetRendererAdSDK` (Media.net's custom renderer).


## Dependencies

- `MediaNetAdSDK` `~> 0.4` (provides `BannerAdView`, the renderer bridge, `MediaNetAdEvent`/`MediaNetPluginEventDelegate`).
- `MediaNetRendererAdSDK` `~> 0.0.20` (the `MNR_ADSDK_FLAVOR` renderer; registers via `MediaNetAdSDKClient`).
- `GoogleMobileAds` `12.x` (GAM event handler / ad sizes) — comes in transitively.
- A single shared `OMSDK_Medianet` (Open Measurement) across the graph.

## Versioning

- Current release: **`0.0.6`**.
- **SPM:** `ios-packages` is pinned with **`exact: "0.4.7"`** so consumers always resolve the tested wrapper + `MNPrebidMobile` pair. Bump FoxSDK when you intentionally move that pin.
- **CocoaPods:** `MediaNetAdSDK` and `MediaNetRendererAdSDK` use exact version requirements matching the SPM graph.
- Source lives in the wrapper repo; binaries and consumer manifests ship from this repo (SPM) and CocoaPods Trunk.


## Environment / constraints

- iOS 16+ (above the renderer's iOS 14 floor and Combine's iOS 13; pinned for headroom).
- Swift 5.9+, Xcode 15+.
- All public callbacks are delivered on the **main thread**; the SDK confines its mutable state to the main queue.
- `getAd(for:)` uses Combine.

## Installation

Swift Package Manager:
```swift
.package(url: "https://github.com/media-net/medianet-fox-sdk.git", from: "0.0.6")
```
Use `exact: "0.0.6"` if you need a bit-for-bit reproducible resolve.

CocoaPods:
```ruby
pod 'MediaNetFoxSDK', '~> 0.0.6'
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

## Design decisions

- **Deferred success** for `getAd(for:)` (publisher emits `.success` only after load; replays a warm view's loaded state on subscribe).
- **Not idempotent**: each `getAd` call yields the next ad in rotation; `position` is informational.
- **Depth-1 warm pool**, single-owner state machine; cancel-before-terminal returns the in-flight ad to the warm slot.
- **Closures** (not a delegate) per the API spec; `AdError`/`AdFinishReason` value types.
- **`didDisplayAd` + skip countdown** are sourced from the `MediaNetAdEvent.adRendered` plugin event; `.completed` from `adComplete` (Prebid-won outstream video only). GAM-served direct/house/AdX creatives emit no plugin events, so the skip countdown falls back to starting when the loaded creative first comes on screen — suppressed for plugin-won ads, which announce themselves with `bidWon`.
- **`contentInsets`** (`UIEdgeInsets`) on `FoxBannerView` insets the ad creative + its bottom chrome (CTA / AdChoices) within the view; set `.bottom` to keep the ad clear of a host tab bar. The skip header stays pinned to the top.
- **ARC `deinit`** teardown; no public `destroy()`.
- `configure` callback param is named `completion:` (idiomatic Swift; the spec's `sdkInitListener` name was not adopted).
