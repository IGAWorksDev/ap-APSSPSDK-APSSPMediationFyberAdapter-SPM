//
//  FyberVideoMixAdapter.swift
//  MediationFyber
//

import UIKit
import APSSPSDK
import IASDKCore

final public class FyberVideoMixAdapter: APSSPVideoMixAdAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?
    public var videoMixDelegate: APSSPVideoMixAdAdapterDelegate?
    public var videoMixAdType: APSSPVideoMixAdType = .RewardVideo
    private var placementDic: [String: String] = [:]
    private var rewardVideoAdapter: FyberRewardVideoAdapter?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        self.placementDic = placementDic; self.rootViewController = rootViewController
        if let ct = placementDic[APSSPPlacementKey.campaignType.rawValue], let v = Int(ct), let t = APSSPVideoMixAdType(rawValue: v) { videoMixAdType = t }
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        self.placementDic = inappbiddingPlacementDic; self.rootViewController = rootViewController
        if let ct = inappbiddingPlacementDic[APSSPPlacementKey.campaignType.rawValue], let v = Int(ct), let t = APSSPVideoMixAdType(rawValue: v) { videoMixAdType = t }
    }

    public func connectVideoMixDelegate(delegate: APSSPVideoMixAdAdapterDelegate) {
        videoMixDelegate = delegate
        switch videoMixAdType {
        case .RewardVideo:
            rewardVideoAdapter = FyberRewardVideoAdapter(placementDic: placementDic, rootViewController: rootViewController, info: [:])
            rewardVideoAdapter?.connectDelegate(delegate: self)
        case .Interstitial, .InterstitialVideo:
            videoMixDelegate?.videoMixAdLoadFail(error: .noAdError, type: videoMixAdType, errorMessage: "Ad type not supported")
        @unknown default:
            break
        }
    }

    public func disconnectVideoMixDelegate() { rewardVideoAdapter = nil; videoMixDelegate = nil }
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        switch videoMixAdType {
        case .RewardVideo: rewardVideoAdapter?.present(from: from) { completion() }
        case .Interstitial, .InterstitialVideo: break
        @unknown default:
            break
        }
    }
    
    public func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}

extension FyberVideoMixAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() { videoMixDelegate?.videoMixAdLoadSuccess(type: videoMixAdType) }
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { videoMixDelegate?.videoMixAdLoadFail(error: error, type: videoMixAdType, errorMessage: errorMessage) }
    public func rewardVideoShowSuccess(message: String) { videoMixDelegate?.videoMixAdShowSuccess(message: message, type: videoMixAdType) }
    public func rewardVideoShowFail(message: String) { videoMixDelegate?.videoMixAdShowFail(message: message, type: videoMixAdType) }
    public func rewardVideoClicked(message: String) { videoMixDelegate?.videoMixAdClicked(message: message, type: videoMixAdType) }
    public func rewardVideoClosed(message: String) { videoMixDelegate?.videoMixAdClosed(message: message, type: videoMixAdType) }
    public func rewardVideoCompleted() { videoMixDelegate?.videoMixAdCompleteTrackingEvent(adNetworkNo: APSSPMediationCompany.Fyber.rawValue, isCompleted: true, type: videoMixAdType) }
}
