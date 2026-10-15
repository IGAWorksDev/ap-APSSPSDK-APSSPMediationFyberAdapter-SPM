//
//  FyberMediationRewardVideoAd.swift
//  MediationVungle
//
//  Created by Odin.송황호 on 6/24/24.
//

import UIKit

import APSSPSDK
import IASDKCore


final class FyberMediationRewardVideoAd: NSObject {
    
    weak var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private weak var rootViewController: UIViewController?
    
    private var biddingData: String?
    
    private var rewardedAd: IAAdSpot?
    
    private var fullscreenUnitController: IAFullscreenUnitController?
    
    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        // 광고는 매체가 present 에 넘긴 화면 위에 띄운다. 로드 때 받은 화면은 그사이 해제됐을 수 있다.
        rootViewController = from
//        self.rewardedAd?.present(with: from)
//        completion()
        if rewardedAd?.activeUnitController == fullscreenUnitController {
            fullscreenUnitController?.showAd(animated: true, completion: {
                completion()
            })
        }
        
        
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Fyber RewardVideo placementId is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        guard let rootViewController else {
            APLogger.error("Fyber must have rootviewController")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "rootViewController is nil")
            return
        }
        
        let adRequest: IAAdRequest? = IAAdRequest.build { builder in
            builder.useSecureConnections = true
            builder.spotID = self.placementId
            builder.timeout = 5
        }
        
        guard let adRequest else {
            self.delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "Fyber RewardVideo IAAdRequest build failed")
            return
        }
        
        guard let viewUnitController: IAVideoContentController = IAVideoContentController.build({ builder in
            builder.videoContentDelegate = self
        }) else { return }
        
        guard let fullscreenUnitController: IAFullscreenUnitController = IAFullscreenUnitController.build ({ builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(viewUnitController)
        }) else { return }
        
        guard let adspot: IAAdSpot = IAAdSpot.build ({ builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(fullscreenUnitController)
        }) else { return }
        
        self.fullscreenUnitController = fullscreenUnitController
        
        if let biddingData = self.biddingData, !biddingData.isEmpty {
            adspot.loadAd(withMarkup: biddingData) { adSpot, IAAdModel, error in
                if let error {
                    APLogger.error("Fyber RewardVideo Bidding Error: \(error.localizedDescription)")
                    self.delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "Fyber RewardVideo load error")
                } else {
                    self.rewardedAd = adSpot
                    self.delegate?.rewardVideoLoadSuccess()
                }
            }
        } else {
            adspot.fetchAd { adSpot, IAAdModel, error in
                if let error {
                    APLogger.error("Fyber RewardVideo Error: \(error.localizedDescription)")
                    self.delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "Fyber RewardVideo load error")
                }
                else {
                    self.delegate?.rewardVideoLoadSuccess()
                }
                
            }
        }
    }
    
    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}


extension FyberMediationRewardVideoAd: IAUnitDelegate, IAVideoContentDelegate {
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    
    func iaVideoContentController(_ contentController: IAVideoContentController?, videoInterruptedWithError error: any Error) {
        APLogger.error("Fyber RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        delegate?.rewardVideoShowSuccess(message: "Fyber RewardVideo is show")
    }
    
    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        delegate?.rewardVideoClicked(message: "Vungle RewardVideo is click")
    }
    
    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        delegate?.rewardVideoClosed(message: "Fyber RewardVideo is closed")
    }
    
    /// 리워드 지급 시점. **완료 통보는 이 콜백을 기준으로 한다.** (IAUnitDelegate, optional)
    ///
    /// 이전에는 `iaVideoCompleted`(영상 재생 완료)에 완료를 걸어두어,
    /// Fyber 가 리워드를 인정하지 않은 건도 완료로 계상돼 과다 정산 소지가 있었다.
    /// ObjC(`FyberAdapter.m:1006 IAAdDidReward`) / AOS(`FyberAdapter.java:657 onAdRewarded`)
    /// 와 동일하게 리워드 콜백에서 통보한다.
    func iaAdDidReward(_ unitController: IAUnitController?) {
        APLogger.debug("Fyber RewardVideo didReward")
        delegate?.rewardVideoCompleted()
    }

    /// 영상 재생 완료. 리워드 지급과는 별개이며 소재 종류에 따라 오지 않을 수 있다.
    /// 완료 통보는 `iaAdDidReward` 에서 한다. (ObjC·AOS 와 동일)
    func iaVideoCompleted(_ contentController: IAVideoContentController?) {
        APLogger.debug("Fyber RewardVideo videoCompleted")
    }
}
