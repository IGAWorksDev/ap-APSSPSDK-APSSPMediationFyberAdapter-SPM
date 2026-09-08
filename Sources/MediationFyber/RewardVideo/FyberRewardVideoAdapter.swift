//
//  FyberRewardVideoAdapter.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK


final public class FyberRewardVideoAdapter: APSSPRewardVideoAdapterInappBiddingProtocol {
    public var rootViewController: UIViewController?

    private var fyberMediationRewardVideoAd: FyberMediationRewardVideoAd?
    
    public var delegate: APSSPRewardVideoAdapterDelegate?
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        fyberMediationRewardVideoAd = FyberMediationRewardVideoAd(placementId: placementId, rootViewController: rootViewController)
        self.fyberMediationRewardVideoAd?.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        fyberMediationRewardVideoAd = FyberMediationRewardVideoAd(placementId: placementId, rootViewController: rootViewController, biddingData: biddingData)
        self.fyberMediationRewardVideoAd?.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPRewardVideoAdapterDelegate) {
        self.delegate = delegate
        self.fyberMediationRewardVideoAd?.load()
    }

    public func disconnectDelegate() {
        fyberMediationRewardVideoAd?.delegate = nil
        delegate = nil
    }
    
    public func present(from: UIViewController, completion: @escaping() -> Void) {
        fyberMediationRewardVideoAd?.present(from: from) { completion() }
    }
    
    public func getBiddingToken() -> String {
        return fyberMediationRewardVideoAd?.getBiddingToken() ?? ""
    }
}




extension FyberRewardVideoAdapter: APSSPRewardVideoAdapterDelegate {
    public func rewardVideoLoadSuccess() {
        delegate?.rewardVideoLoadSuccess()
    }
    
    public func rewardVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.rewardVideoLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func rewardVideoShowSuccess(message: String) {
        delegate?.rewardVideoShowSuccess(message: message)
    }
    
    public func rewardVideoShowFail(message: String) {
        delegate?.rewardVideoShowFail(message: message)
    }
    
    public func rewardVideoClicked(message: String) {
        delegate?.rewardVideoClicked(message: message)
    }
    
    public func rewardVideoClosed(message: String) {
        delegate?.rewardVideoClosed(message: message)
    }
    
    public func rewardVideoCompleted() {
        delegate?.rewardVideoCompleted()
    }
}
