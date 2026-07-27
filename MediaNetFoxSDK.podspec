# Created by Ahmed Ragab Issa.
Pod::Spec.new do |s|
  s.name             = 'MediaNetFoxSDK'
  s.version          = '0.0.8'
  s.summary          = 'Fox-shaped vertical-video (Shorts) ad SDK on top of MediaNetAdSDK.'
  s.description      = <<~DESC
    MediaNetFoxSDK interleaves and prefetches ads for vertical-video feeds. It
    layers on the MediaNetAdSDK Prebid wrapper plus the AdSDK-flavor
    MediaNetRendererAdSDK renderer, exposing `configure`, `isAd(at:)`,
    `getAd(for:)` (Combine), and a `FoxBannerView` with a built-in skip header.
    The public entry point is `MediaNetFoxSDKClient.shared` (the module is
    `MediaNetFoxSDK`).

    Display + completion events flow through the renderer's AdSDK-flavor
    publisher-event channel (`MediaNetPluginEventDelegate.onEvent(MediaNetAdEvent)`),
    so this pod requires `MediaNetRendererAdSDK` (the `MNR_ADSDK_FLAVOR` build),
    NOT the default `MediaNetRenderer`/`MediaNetRendererPrebid` flavor.
  DESC

  s.homepage          = 'https://github.com/media-net/medianet-fox-sdk'
  s.license           = { :type => 'Commercial' }
  s.author            = { 'Media.net' => 'mobile@media.net' }

  s.platform          = :ios, '16.0'
  s.swift_versions    = ['5.9']

  # Binary distribution: the prebuilt xcframework is hosted as a GitHub release
  # asset on the dedicated medianet-fox-sdk repo (mirrors MediaNetAdSDK). The
  # PrivacyInfo.xcprivacy ships inside the .framework bundle, so no resource_bundle.
  s.source            = { :http => "https://github.com/media-net/medianet-fox-sdk/releases/download/#{s.version}/MediaNetFoxSDK.xcframework.zip" }
  s.vendored_frameworks = 'MediaNetFoxSDK.xcframework'
  s.static_framework  = true
  # Static frameworks don't carry their flat resources into the host app, so the
  # privacy manifest ships as a CocoaPods resource bundle (the release script
  # stages MediaNetFoxSDKResources/ alongside the xcframework in the zip).
  s.resource_bundles  = { 'MediaNetFoxSDKResources' => ['MediaNetFoxSDKResources/*'] }

  # AdSDK-flavor renderer is mandatory (publisher-event channel). All three are
  # on CocoaPods Trunk; GoogleMobileAds is used directly for GAM ad sizes.
  # Exact pins (not floors) guarantee consumers resolve this tested
  # wrapper+renderer combination rather than silently picking a different
  # patch. Post repo-split versions: MediaNetAdSDK 0.4.8 releases from
  # MediaNetAdSDK-dist; MediaNetRendererAdSDK 0.5.0 is the first renderer-only
  # ios-packages release. These pins are stamped by the release script from the
  # same variables as the SPM pins (they drifted when hand-maintained).
  s.dependency 'MediaNetAdSDK', '0.4.8'
  s.dependency 'MediaNetRendererAdSDK', '0.5.0'
  s.dependency 'Google-Mobile-Ads-SDK', '~> 12.3'
end
