//
//  FyberUnifiedNativeAdapter.swift
//  MediationFyber
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import APSSPSDK


final public class FyberUnifiedNativeAdapter: APSSPUnifiedNativeAdapterInAppBiddingProtocol {
    
    public weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    public weak var rootViewController: UIViewController?
    public var viewBinder: APSSPMediationViewBinder
    public var config: APSSPNativeAdConfig?
    
    private var mediationView: FyberMediationUnifiedNativeAdView
    
    // MARK: - Waterfall 초기화
    
    public required init(placementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        let biddingData = placementDic[APSSPBiddingKey.biddingData.rawValue]
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = FyberMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config,
            biddingData: biddingData
        )
    }
    
    // MARK: - InApp Bidding 초기화
    
    public required init(inappBiddingPlacementDic: [String: String],
                         rootViewController: UIViewController?,
                         viewBinder: APSSPMediationViewBinder,
                         config: APSSPNativeAdConfig?,
                         info: [String: Any?]) {
        let placementId = inappBiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappBiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue]
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.mediationView = FyberMediationUnifiedNativeAdView(
            placementId: placementId,
            rootViewController: rootViewController,
            viewBinder: viewBinder,
            config: config,
            biddingData: biddingData
        )
    }
    
    // MARK: - Bidding Token
    
    public func getBiddingToken() -> String {
        return mediationView.getBiddingToken()
    }
    
    // MARK: - Protocol Methods
    
    public func connectDelegate(delegate: APSSPUnifiedNativeAdapterDelegate) {
        self.delegate = delegate
        mediationView.delegate = self
        mediationView.load()
    }
    
    public func disconnectDelegate() { mediationView.delegate = nil; delegate = nil }
    public func stop() { mediationView.stop() }
}

extension FyberUnifiedNativeAdapter: APSSPUnifiedNativeAdapterDelegate {
    public func unifiedNativeLoadSuccess() { delegate?.unifiedNativeLoadSuccess() }
    public func unifiedNativeLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.unifiedNativeLoadFail(error: error, errorMessage: errorMessage) }
    public func unifiedNativeClicked(message: String) { delegate?.unifiedNativeClicked(message: message) }
    public func unifiedNativeImpression(message: String) { delegate?.unifiedNativeImpression(message: message) }
}
