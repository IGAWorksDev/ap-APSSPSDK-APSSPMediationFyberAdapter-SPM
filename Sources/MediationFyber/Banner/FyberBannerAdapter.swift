import UIKit
import APSSPSDK

final public class FyberBannerAdapter: APSSPBannerAdapterInappBiddingProtocol {

    private let fyberBannerView: FyberMediationBannerView

    weak public var delegate: APSSPBannerAdapterDelegate?
    weak public var rootViewController: UIViewController?

    public init(placementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?, info: [String: Any?]) {
        let placementId = placementDic[APSSPPlacementKey.fyberSpotId.rawValue] ?? ""
        self.fyberBannerView = FyberMediationBannerView(placementId: placementId, bannerType: bannerType, rootViewController: rootViewController)
        self.rootViewController = rootViewController
        fyberBannerView.delegate = self
    }

    public init(inappbiddingPlacementDic: [String: String], bannerType: APSSPBannerSize, rootViewController: UIViewController?) {
        let placementId = inappbiddingPlacementDic[APSSPBiddingKey.fyberPlacementId.rawValue] ?? ""
        let biddingData = inappbiddingPlacementDic[APSSPBiddingKey.biddingData.rawValue] ?? ""
        self.fyberBannerView = FyberMediationBannerView(placementId: placementId, bannerType: bannerType, rootViewController: rootViewController, biddingData: biddingData)
        self.rootViewController = rootViewController
        fyberBannerView.delegate = self
    }

    public func connectDelegate(delegate: APSSPBannerAdapterDelegate) {
        self.delegate = delegate
        fyberBannerView.load()
    }

    public func disconnectDelegate() {
        fyberBannerView.delegate = nil
        delegate = nil
    }

    public func stop() {
        fyberBannerView.stop()
    }

    public func getBiddingToken() -> String {
        return fyberBannerView.getBiddingToken()
    }
}

extension FyberBannerAdapter: APSSPBannerAdapterDelegate {
    public func bannerViewSuccess(bannerView: UIView) {
        delegate?.bannerViewSuccess(bannerView: bannerView)
    }

    public func bannerViewFailed(bannerView: UIView, error: APSSPNetworkError, errorMessage: String?) {
        delegate?.bannerViewFailed(bannerView: UIView(), error: .nextMediation, errorMessage: errorMessage)
    }

    public func bannerViewClicked(message: String) {
        delegate?.bannerViewClicked(message: message)
    }

    public func bannerViewImpression(message: String) {
        delegate?.bannerViewImpression(message: message)
    }
}
