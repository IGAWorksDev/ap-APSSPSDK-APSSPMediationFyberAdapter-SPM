import UIKit
import APSSPSDK
import IASDKCore

@objc(APSSPFyberAdapterFactory)
public final class FyberAdapterFactory: NSObject, APSSPAdapterFactory {

    public static var networkID: Int { 16 }

    public static var sdkVersion: String? { FyberInitializationAdapter().sdkVersion }
    public static var adapterVersion: String? { "8.4.2.0" }

    public static func makeInitializationAdapter() -> AnyObject? {
        return FyberInitializationAdapter()
    }

    public static func makeBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FyberBannerAdapter(placementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FyberInterstitialAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FyberInterstitialVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FyberRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    public static func makeNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return FyberNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any]) -> AnyObject? {
        return FyberVideoMixAdapter(placementDic: placementDic, rootViewController: rootViewController, info: info)
    }

    // MARK: - Bidding

    public static func makeBiddingBannerAdapter(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) -> AnyObject? {
        return FyberBannerAdapter(inappbiddingPlacementDic: placementDic, bannerType: bannerType, rootViewController: rootViewController)
    }

    public static func makeBiddingInterstitialAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FyberInterstitialAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingInterstitialVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FyberInterstitialVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingRewardVideoAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FyberRewardVideoAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeBiddingNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String: Any]) -> AnyObject? {
        return FyberNativeAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController, render: render, info: info)
    }

    public static func makeBiddingVideoMixAdapter(placementDic: [String: String], rootViewController: UIViewController?) -> AnyObject? {
        return FyberVideoMixAdapter(inappbiddingPlacementDic: placementDic, rootViewController: rootViewController)
    }

    public static func makeUnifiedNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, info: [String: Any]) -> AnyObject? {
        return FyberUnifiedNativeAdapter(placementDic: placementDic, rootViewController: rootViewController, viewBinder: viewBinder, config: config, info: info)
    }

    public static func makeBiddingUnifiedNativeAdapter(placementDic: [String: String], rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, info: [String: Any]) -> AnyObject? {
        return FyberUnifiedNativeAdapter(inappBiddingPlacementDic: placementDic, rootViewController: rootViewController, viewBinder: viewBinder, config: config, info: info)
    }
}
