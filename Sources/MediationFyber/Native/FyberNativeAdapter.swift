//
//  FyberNativeAdapter.swift
//  MediationFyber
//

import UIKit

import APSSPSDK


final public class FyberNativeAdapter: APSSPNativeAdapterInappBiddingProtocol {
    
    public var render: AnyObject?
    
    weak public var delegate: APSSPNativeViewAdapterDelegate?
    
    public var rootViewController: UIViewController?
    
    private var nativeAdView: FyberMediationNativeAdView
    
    public init(placementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        self.nativeAdView = FyberMediationNativeAdView(placementId: placementId, rootViewController: rootViewController)
        self.nativeAdView.fyberRenderer = render as? APSSPFyberNativeAdRenderer
        nativeAdView.delegate = self
    }
    
    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?, render: AnyObject, info: [String : Any?]) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.nativeAdView = FyberMediationNativeAdView(placementId: placementId, rootViewController: rootViewController, biddingData: biddingData)
        self.nativeAdView.fyberRenderer = render as? APSSPFyberNativeAdRenderer
        nativeAdView.delegate = self
    }
    
    public func connectDelegate(delegate: APSSPNativeViewAdapterDelegate) {
        self.delegate = delegate
        nativeAdView.delegate = self
        nativeAdView.load()
    }
    
    public func disconnectDelegate() {
        nativeAdView.delegate = nil
        delegate = nil
    }
    
    public func stop() {
        nativeAdView.delegate = nil
    }
    
    public func getBiddingToken() -> String {
        return nativeAdView.getBiddingToken()
    }
}


extension FyberNativeAdapter: APSSPNativeViewAdapterDelegate {
    public func nativeLoadSuccess() {
        delegate?.nativeLoadSuccess()
    }
    
    public func nativeLoadFail(error: APSSPNetworkError, errorMessage: String?) {
        delegate?.nativeLoadFail(error: error, errorMessage: errorMessage)
    }
    
    public func nativeClicked(message: String) {
        delegate?.nativeClicked(message: message)
    }
    
    public func nativeImpression(message: String) {
        delegate?.nativeImpression(message: message)
    }
}
