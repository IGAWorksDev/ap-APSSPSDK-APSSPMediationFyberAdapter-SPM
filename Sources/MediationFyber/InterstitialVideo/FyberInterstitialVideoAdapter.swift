import UIKit
import APSSPSDK

final public class FyberInterstitialVideoAdapter: APSSPInterstitialVideoAdapterInappBiddingProtocol {

    public var delegate: APSSPInterstitialVideoAdapterDelegate?
    public var rootViewController: UIViewController?

    private var fyberMediationInterstitialVideoAd: FyberMediationInterstitialVideoAd?

    public init(placementDic: [String: String], rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        fyberMediationInterstitialVideoAd = FyberMediationInterstitialVideoAd(placementId: placementId, rootViewController: rootViewController)
        fyberMediationInterstitialVideoAd?.delegate = self
    }

    public init(inappbiddingPlacementDic: [String: String], rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        fyberMediationInterstitialVideoAd = FyberMediationInterstitialVideoAd(placementId: placementId, rootViewController: rootViewController, biddingData: biddingData)
        fyberMediationInterstitialVideoAd?.delegate = self
    }

    public func connectDelegate(delegate: APSSPInterstitialVideoAdapterDelegate) {
        self.delegate = delegate
        fyberMediationInterstitialVideoAd?.load()
    }

    public func disconnectDelegate() {
        fyberMediationInterstitialVideoAd?.delegate = nil
        delegate = nil
    }

    public func present(from: UIViewController, completion: @escaping () -> Void) {
        fyberMediationInterstitialVideoAd?.present(from: from) { completion() }
    }

    public func getBiddingToken() -> String {
        return fyberMediationInterstitialVideoAd?.getBiddingToken() ?? ""
    }
}

extension FyberInterstitialVideoAdapter: APSSPInterstitialVideoAdapterDelegate {
    public func interstitialVideoLoadSuccess() { delegate?.interstitialVideoLoadSuccess() }
    public func interstitialVideoLoadFail(error: APSSPNetworkError, errorMessage: String?) { delegate?.interstitialVideoLoadFail(error: error, errorMessage: errorMessage) }
    public func interstitialVideoShowSuccess(message: String) { delegate?.interstitialVideoShowSuccess(message: message) }
    public func interstitialVideoShowFail(message: String) { delegate?.interstitialVideoShowFail(message: message) }
    public func interstitialVideoClicked(message: String) { delegate?.interstitialVideoClicked(message: message) }
    public func interstitialVideoClosed(message: String) { delegate?.interstitialVideoClosed(message: message) }
}
