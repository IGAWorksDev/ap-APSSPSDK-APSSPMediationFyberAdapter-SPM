import UIKit
import APSSPSDK
import IASDKCore

final class FyberMediationInterstitialVideoAd: NSObject {

    weak var delegate: APSSPInterstitialVideoAdapterDelegate?

    private let placementId: String
    private weak var rootViewController: UIViewController?
    private var biddingData: String?

    private var adSpot: IAAdSpot?
    private var fullscreenUnitController: IAFullscreenUnitController?
    private var videoContentController: IAVideoContentController?

    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
    }

    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }

    func present(from: UIViewController, completion: @escaping () -> Void) {
        // 광고는 매체가 present 에 넘긴 화면 위에 띄운다. 로드 때 받은 화면은 그사이 해제됐을 수 있다.
        rootViewController = from
        if adSpot?.activeUnitController == fullscreenUnitController {
            fullscreenUnitController?.showAd(animated: true, completion: {
                completion()
            })
        } else {
            delegate?.interstitialVideoShowFail(message: "Fyber InterstitialVideo not loaded")
        }
    }

    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Fyber InterstitialVideo placementId is empty")
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        let adRequest = IAAdRequest.build { builder in
            builder.useSecureConnections = true
            builder.spotID = self.placementId
            builder.timeout = 10
        }

        guard let adRequest else {
            delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "Fyber adRequest is nil")
            return
        }

        let video = IAVideoContentController.build { builder in
            builder.videoContentDelegate = self
        }
        videoContentController = video

        let fullscreen = IAFullscreenUnitController.build { builder in
            builder.unitDelegate = self
            if let video { builder.addSupportedContentController(video) }
        }
        fullscreenUnitController = fullscreen

        let spot = IAAdSpot.build { builder in
            builder.adRequest = adRequest
            if let fullscreen { builder.addSupportedUnitController(fullscreen) }
        }
        adSpot = spot

        let fetchCompletion: (IAAdSpot?, IAAdModel?, Error?) -> Void = { [weak self] _, _, error in
            guard let self else { return }
            if error != nil {
                APLogger.error("Fyber InterstitialVideo load error")
                self.delegate?.interstitialVideoLoadFail(error: .nextMediation, errorMessage: "Fyber InterstitialVideo load error")
            } else {
                self.delegate?.interstitialVideoLoadSuccess()
            }
        }

        if let biddingData, !biddingData.isEmpty {
            spot?.loadAd(withMarkup: biddingData, withCompletion: fetchCompletion)
        } else {
            spot?.fetchAd(completion: fetchCompletion)
        }
    }
}

extension FyberMediationInterstitialVideoAd: IAUnitDelegate, IAVideoContentDelegate {
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }

    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        delegate?.interstitialVideoShowSuccess(message: "Fyber InterstitialVideo show")
    }

    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        delegate?.interstitialVideoClicked(message: "Fyber InterstitialVideo click")
    }

    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        delegate?.interstitialVideoClosed(message: "Fyber InterstitialVideo closed")
    }
}
