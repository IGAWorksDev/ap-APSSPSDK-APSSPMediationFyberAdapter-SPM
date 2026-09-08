import UIKit
import APSSPSDK

final public class FyberInterstitialAdapter: APSSPInterstitialAdapterInappBiddingProtocol {

    public var rootViewController: UIViewController?
    public var delegate: APSSPInterstitialAdapterDelegate?

    private var fyberMediationInterstitialAd: FyberMediationInterstitialAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        fyberMediationInterstitialAd = FyberMediationInterstitialAd(placementId: placementId, rootViewController: rootViewController)
        fyberMediationInterstitialAd?.delegate = self
    }

    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        fyberMediationInterstitialAd = FyberMediationInterstitialAd(placementId: placementId, rootViewController: rootViewController, biddingData: biddingData)
        fyberMediationInterstitialAd?.delegate = self
    }

    public func connectDelegate(delegate: APSSPInterstitialAdapterDelegate) {
        self.delegate = delegate
        fyberMediationInterstitialAd?.load()
    }

    public func disconnectDelegate() {
        fyberMediationInterstitialAd?.delegate = nil
        delegate = nil
    }

    public func present(from: UIViewController, completion: () -> Void) {
        fyberMediationInterstitialAd?.present(from: from) { completion() }
    }

    public func getBiddingToken() -> String {
        return fyberMediationInterstitialAd?.getBiddingToken() ?? ""
    }
}

extension FyberInterstitialAdapter: APSSPInterstitialAdapterDelegate {
    public func interstitialLoadSuccess() { delegate?.interstitialLoadSuccess() }
    public func interstitialLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.interstitialLoadFail(error: error, errorMessage: errorMessage) }
    public func interstitialShowSuccess(message: String) { delegate?.interstitialShowSuccess(message: message) }
    public func interstitialShowFail(message: String) { delegate?.interstitialShowFail(message: message) }
    public func interstitialClicked(message: String) { delegate?.interstitialClicked(message: message) }
    public func interstitialClosed(message: String) { delegate?.interstitialClosed(message: message) }
}
