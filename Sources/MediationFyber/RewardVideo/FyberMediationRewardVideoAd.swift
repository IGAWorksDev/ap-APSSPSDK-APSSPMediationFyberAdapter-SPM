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
    
    var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let rootViewController: UIViewController?
    
    private var biddingData: String?
    
    private var rewardedAd: IAAdSpot?
    
    private var fullscreenUnitController: IAFullscreenUnitController?
    
    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
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
        return rootViewController!
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
    
    func iaVideoCompleted(_ contentController: IAVideoContentController?) {
        delegate?.rewardVideoCompleted()
    }
}
