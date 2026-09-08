import UIKit
import APSSPSDK
import IASDKCore

final class FyberMediationBannerView: UIView {

    weak var delegate: APSSPBannerAdapterDelegate?
    weak private var rootViewController: UIViewController?

    private let placementId: String
    private let bannerType: APSSPBannerSize
    private var biddingData: String?

    private var adSpot: IAAdSpot?
    private var bannerViewController: IAViewUnitController?
    private var mraidContentController: IAMRAIDContentController?

    init(placementId: String, bannerType: APSSPBannerSize, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.bannerType = bannerType
        self.rootViewController = rootViewController
        self.biddingData = biddingData
        super.init(frame: CGRect(x: 0, y: 0, width: bannerType.width, height: bannerType.height))
    }

    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Fyber Banner placementId is empty")
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let adRequest = IAAdRequest.build { builder in
            builder.useSecureConnections = true
            builder.spotID = self.placementId
            builder.timeout = 10
        }

        guard let adRequest else {
            delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "Fyber adRequest is nil")
            return
        }

        let mraid = IAMRAIDContentController.build { builder in
            builder.mraidContentDelegate = self
        }
        mraidContentController = mraid

        let viewUnit = IAViewUnitController.build { builder in
            builder.unitDelegate = self
            if let mraid { builder.addSupportedContentController(mraid) }
        }
        bannerViewController = viewUnit

        let spot = IAAdSpot.build { builder in
            builder.adRequest = adRequest
            if let viewUnit { builder.addSupportedUnitController(viewUnit) }
        }
        adSpot = spot

        let fetchCompletion: (IAAdSpot?, IAAdModel?, Error?) -> Void = { [weak self] _, _, error in
            guard let self else { return }
            if error != nil {
                APLogger.error("Fyber Banner load error")
                self.delegate?.bannerViewFailed(bannerView: self, error: .nextMediation, errorMessage: "Fyber Banner load error")
            } else {
                if let adView = self.bannerViewController?.adView {
                    self.setupAdView(adView)
                }
                self.delegate?.bannerViewSuccess(bannerView: self)
            }
        }

        if let biddingData, !biddingData.isEmpty {
            spot?.loadAd(withMarkup: biddingData, withCompletion: fetchCompletion)
        } else {
            spot?.fetchAd(completion: fetchCompletion)
        }
    }

    func stop() {
        mraidContentController = nil
        bannerViewController = nil
        adSpot = nil
    }

    private func setupAdView(_ adView: UIView) {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: centerYAnchor),
            adView.widthAnchor.constraint(equalToConstant: bannerType.width),
            adView.heightAnchor.constraint(equalToConstant: bannerType.height)
        ])
    }
}

extension FyberMediationBannerView: IAUnitDelegate, IAMRAIDContentDelegate {
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    func iaMRAIDContentController(_ contentController: IAMRAIDContentController?, mraidAdDidPresent ad: IAAdModel?) {}
    func iaMRAIDContentController(_ contentController: IAMRAIDContentController?, mraidAdDidClose ad: IAAdModel?) {}

    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        delegate?.bannerViewClicked(message: "Fyber Banner Click")
    }
}
