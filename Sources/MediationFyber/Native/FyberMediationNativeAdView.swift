//
//  FyberMediationNativeAdView.swift
//  MediationFyber
//

import UIKit

import APSSPSDK
import IASDKCore

@objc
public final class APSSPFyberNativeAdRenderer: NSObject, APSSPNativeRenderer {
    @objc public var contentView: UIView?
    @objc public var nativeAdView: UIView?
    @objc public var titleLabel: UILabel?
    @objc public var descriptionLabel: UILabel?
    @objc public var ctaButton: UIButton?
    @objc public var iconImageView: UIImageView?
    @objc public var mediaContainerView: UIView?
}


final class FyberMediationNativeAdView: NSObject {
    
    var delegate: APSSPNativeViewAdapterDelegate?
    
    private let placementId: String
    
    private weak var rootViewController: UIViewController?
    
    private var biddingData: String?
    
    private var nativeAdSpot: IANativeAdSpot?
    private var nativeAdAssets: IANativeAdAssets?
    
    var fyberRenderer: APSSPFyberNativeAdRenderer?
    
    init(placementId: String, rootViewController: UIViewController?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.biddingData = biddingData
    }
    
    func load() {
        guard !placementId.isEmpty else {
            APLogger.error("Fyber Native placementId is empty")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "placementId is empty")
            return
        }
        
        // Fyber Native는 bidding only
        guard let biddingData else {
            APLogger.error("Fyber Native only provides bidding")
            delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber adRequest is nil")
            return
        }
        
        let adRequest = IAAdRequest.build { builder in
            builder.spotID = self.placementId
            builder.timeout = 10
        }
        
        let nativeAdSpot = IANativeAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.delegate = self
        }
        
        self.nativeAdSpot = nativeAdSpot
        APLogger.debug("Start Fyber Native load, placementId: \(placementId)")
        
        nativeAdSpot.loadAd(withMarkup: biddingData) { [weak self] nativeAdAssets, error in
            guard let self else { return }
            if let error {
                APLogger.error("Fyber Native Error: \(error.localizedDescription)")
                self.delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native load error")
                return
            }
            
            guard let nativeAdAssets else {
                self.delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native ad data is nil")
                return
            }
            
            // nativeAdAssets를 strong으로 보유 (gesture target이 해제되지 않도록)
            self.nativeAdAssets = nativeAdAssets
            
            // renderer에 nativeAdAssets 바인딩
            APLogger.debug("Fyber Native Success")
            
            if let renderer = self.fyberRenderer {
                renderer.titleLabel?.text = nativeAdAssets.adTitle
                renderer.descriptionLabel?.text = nativeAdAssets.adDescription
                renderer.ctaButton?.setTitle(nativeAdAssets.callToActionText, for: .normal)
                
                // Icon
                if let iconView = nativeAdAssets.appIcon, let imageView = renderer.iconImageView {
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    imageView.superview?.insertSubview(iconView, aboveSubview: imageView)
                    NSLayoutConstraint.activate([
                        iconView.topAnchor.constraint(equalTo: imageView.topAnchor),
                        iconView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                        iconView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                        iconView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
                    ])
                    imageView.isHidden = true
                }
                
                // MediaView → mediaContainerView에 삽입
                let mediaView = nativeAdAssets.mediaView
                mediaView.isUserInteractionEnabled = true
                if let mediaContainer = renderer.mediaContainerView {
                    mediaView.translatesAutoresizingMaskIntoConstraints = false
                    mediaContainer.subviews.forEach { $0.removeFromSuperview() }
                    mediaContainer.addSubview(mediaView)
                    NSLayoutConstraint.activate([
                        mediaView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
                        mediaView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
                        mediaView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
                        mediaView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
                    ])
                } else if let nativeAdView = renderer.nativeAdView {
                    // mediaContainerView 없으면 nativeAdView 뒤에 깔기
                    mediaView.translatesAutoresizingMaskIntoConstraints = false
                    nativeAdView.insertSubview(mediaView, at: 0)
                    NSLayoutConstraint.activate([
                        mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
                        mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
                        mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
                        mediaView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor)
                    ])
                }
                
                // registerViewForInteraction
                // rootView는 실제 화면에 표시되고 있는 공통 superview를 사용
                // (renderer.nativeAdView는 Fyber SDK가 removeFromSuperview 할 수 있으므로 사용 불가)
                let rootView: UIView
                if let titleSuperview = renderer.titleLabel?.superview, titleSuperview.window != nil {
                    rootView = titleSuperview
                } else if let nativeAdView = renderer.nativeAdView {
                    rootView = nativeAdView
                } else {
                    self.delegate?.nativeLoadFail(error: .nextMediation, errorMessage: "No valid rootView for Fyber")
                    return
                }
                
                rootView.tag = 8  // root
                nativeAdAssets.mediaView.tag = 2  // mediaView
                renderer.titleLabel?.tag = 1
                renderer.descriptionLabel?.tag = 5
                renderer.ctaButton?.tag = 7
                renderer.iconImageView?.tag = 4
                    
                var clickableViews: [UIView] = []
                if let title = renderer.titleLabel { clickableViews.append(title) }
                if let desc = renderer.descriptionLabel { clickableViews.append(desc) }
                if let cta = renderer.ctaButton { clickableViews.append(cta) }
                    
                nativeAdAssets.registerViewForInteraction(rootView: rootView,
                                                          mediaView: nativeAdAssets.mediaView,
                                                          iconView: nativeAdAssets.appIcon ?? renderer.iconImageView,
                                                          clickableViews: clickableViews)
                
                renderer.contentView = renderer.nativeAdView
            }
            
            self.delegate?.nativeLoadSuccess()
        }
    }
    
    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}


extension FyberMediationNativeAdView: IANativeAdDelegate {
    func iaParentViewController(forAdSpot adSpot: IANativeAdSpot?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    
    func iaNativeAdDidReceiveClick(_ adSpot: IANativeAdSpot?, origin: String?) {
        delegate?.nativeClicked(message: "Fyber Native Clicked")
    }
    
    func iaNativeAdWillLogImpression(_ adSpot: IANativeAdSpot?) {
        delegate?.nativeImpression(message: "Fyber Native Impression")
    }
}
