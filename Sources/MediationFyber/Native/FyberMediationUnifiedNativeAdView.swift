//
//  FyberMediationUnifiedNativeAdView.swift
//  MediationFyber
//
//  Created by Odin on 2026/07/06.
//

import UIKit
import IASDKCore
import APSSPSDK


/// Fyber Native Ad에서 뷰 상호작용 등록 시 사용하는 ViewTag
private enum FyberViewTag: Int {
    case title = 1
    case mediaView = 2
    case icon = 4
    case description = 5
    case rating = 6
    case cta = 7
    case root = 8
}


final class FyberMediationUnifiedNativeAdView: NSObject {
    
    weak var delegate: APSSPUnifiedNativeAdapterDelegate?
    
    private let placementId: String
    private weak var rootViewController: UIViewController?
    private let viewBinder: APSSPMediationViewBinder
    private let config: APSSPNativeAdConfig?
    private var biddingData: String?
    
    private var nativeAdSpot: IANativeAdSpot?
    private var nativeAdAssets: IANativeAdAssets?

    /// 신규(레시피) 방식에서 생성한 매체 화면
    private var contentView: APSSPUnifiedNativeAdView?


    init(placementId: String, rootViewController: UIViewController?, viewBinder: APSSPMediationViewBinder, config: APSSPNativeAdConfig?, biddingData: String? = nil) {
        self.placementId = placementId
        self.rootViewController = rootViewController
        self.viewBinder = viewBinder
        self.config = config
        self.biddingData = biddingData
    }
    
    func load() {
        guard !placementId.isEmpty else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber placementId is empty")
            return
        }
        
        // Fyber Native는 bidding only
        guard let biddingData else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber Native requires bidding data")
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
        
        nativeAdSpot.loadAd(withMarkup: biddingData) { [weak self] nativeAdAssets, error in
            guard let self else { return }
            if let error {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
                return
            }
            
            guard let nativeAdAssets else {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber ad assets is nil")
                return
            }
            
            // nativeAdAssets를 strong으로 보유 (gesture target이 해제되지 않도록)
            self.nativeAdAssets = nativeAdAssets

            if self.viewBinder.isContentViewMode {
                APLogger.debug("Fyber UnifiedNative → 매체 XIB (신규 구조)")
                guard self.handleAdAssetsWithContentView(nativeAdAssets) else { return }
                self.delegate?.unifiedNativeLoadSuccess()
                return
            }

            // ViewBinder 바인딩
            self.viewBinder.titleLabel?.text = nativeAdAssets.adTitle
            self.viewBinder.bodyLabel?.text = nativeAdAssets.adDescription
            self.viewBinder.ctaButton?.setTitle(nativeAdAssets.callToActionText, for: .normal)
            
            // Icon → iconImageView 위에 overlay
            if let iconView = nativeAdAssets.appIcon, let imageView = self.viewBinder.iconImageView {
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
            self.viewBinder.insertMediaView(mediaView)
            
            self.viewBinder.hideAllOptionalViews()
            
            // containerView를 rootView로 사용
            guard let container = self.viewBinder.containerView else {
                self.delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "containerView is nil")
                return
            }
            
            // ViewTag 설정
            container.tag = FyberViewTag.root.rawValue
            mediaView.tag = FyberViewTag.mediaView.rawValue
            self.viewBinder.titleLabel?.tag = FyberViewTag.title.rawValue
            self.viewBinder.bodyLabel?.tag = FyberViewTag.description.rawValue
            self.viewBinder.ctaButton?.tag = FyberViewTag.cta.rawValue
            let iconHolder = nativeAdAssets.appIcon ?? self.viewBinder.iconImageView
            iconHolder?.tag = FyberViewTag.icon.rawValue
            
            // Register Views for Interaction (클릭 이벤트 등록)
            var clickableViews: [UIView] = []
            if let title = self.viewBinder.titleLabel { clickableViews.append(title) }
            if let body = self.viewBinder.bodyLabel { clickableViews.append(body) }
            if let cta = self.viewBinder.ctaButton { clickableViews.append(cta) }
            
            nativeAdAssets.registerViewForInteraction(rootView: container,
                                                      mediaView: mediaView,
                                                      iconView: iconHolder,
                                                      clickableViews: clickableViews)
            
            self.delegate?.unifiedNativeLoadSuccess()
        }
    }
    
    func stop() {
        nativeAdSpot = nil
        nativeAdAssets = nil
        contentView?.removeFromSuperview()
        contentView = nil
    }

    func getBiddingToken() -> String {
        return FMPBiddingManager.sharedInstance().biddingToken() ?? ""
    }
}


// MARK: - [NEW] ContentView 방식 — 매체가 만든 화면(APSSPUnifiedNativeAdView)을 사용
private extension FyberMediationUnifiedNativeAdView {

    /// 매체가 만든 화면(`APSSPUnifiedNativeAdView`)을 플레이스홀더에 부착하고,
    /// 그 화면 자신을 register rootView로 넘긴다.
    /// Fyber는 컨테이너 클래스가 없으므로 clickableViews가 rootView의 자손이기만 하면 되며,
    /// 추가로 **ViewTag 규약**을 함께 지켜야 한다.
    /// - Returns: 조립 성공 여부. `false`면 이미 `unifiedNativeLoadFail`이 호출된 상태다.
    func handleAdAssetsWithContentView(_ nativeAdAssets: IANativeAdAssets) -> Bool {
        guard let placeholder = viewBinder.resolvedPlaceholder else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber placeholder is nil")
            return false
        }

        guard let content = viewBinder.makeContentView() else {
            delegate?.unifiedNativeLoadFail(error: .nextMediation, errorMessage: "Fyber contentView 생성 실패")
            return false
        }
        self.contentView = content

        // 1. 먼저 부착 — register 시점에 계층이 완성되어 있어야 한다.
        APSSPUnifiedNativeAssembler.attach(content, to: placeholder)

        // 2. 빈 슬롯 채우기 — MediaView는 Fyber SDK가 제공
        let mediaView = nativeAdAssets.mediaView
        mediaView.isUserInteractionEnabled = true
        if !APSSPUnifiedNativeAssembler.fillSlot(content.mediaContainerView, with: mediaView) {
            APLogger.error("Fyber UnifiedNative: mediaContainerView가 없습니다. XIB에 빈 컨테이너를 배치하세요.")
        }

        // 3. Icon — Fyber의 appIcon은 UIView라 매체 UIImageView를 그대로 쓸 수 없다.
        //    매체 iconImageView를 슬롯처럼 사용해 그 안에 채운다.
        var iconHolder: UIView? = content.iconImageView
        var hasIconAsset = false
        if let appIcon = nativeAdAssets.appIcon,
           APSSPUnifiedNativeAssembler.fillSlot(content.iconImageView, with: appIcon) {
            // UIImageView는 기본적으로 터치를 받지 않으므로 자식 클릭을 위해 활성화
            content.iconImageView?.isUserInteractionEnabled = true
            iconHolder = appIcon
            hasIconAsset = true
        }

        // 4. 데이터 바인딩
        content.titleLabel?.text = nativeAdAssets.adTitle
        content.bodyLabel?.text = nativeAdAssets.adDescription
        content.ctaButton?.setTitle(nativeAdAssets.callToActionText, for: .normal)

        var visibleKeys = Set<APSSPUnifiedNativeAdView.OptionalKey>()
        // 별점은 숫자로만 오므로 SDK가 화면에 반영한다.
        content.updateStarRating(nativeAdAssets.rating)
        content.hideOptionalViews(except: visibleKeys)

        // 5. ViewTag 규약 (Fyber가 태그로 각 에셋을 식별한다 — 신규 경로에서도 필수)
        content.tag = FyberViewTag.root.rawValue
        mediaView.tag = FyberViewTag.mediaView.rawValue
        content.titleLabel?.tag = FyberViewTag.title.rawValue
        content.bodyLabel?.tag = FyberViewTag.description.rawValue
        content.ctaButton?.tag = FyberViewTag.cta.rawValue
        content.starRatingView?.tag = FyberViewTag.rating.rawValue
        iconHolder?.tag = FyberViewTag.icon.rawValue

        // 6. register — rootView는 content 자신 (반드시 마지막)
        //    icon은 iconView 파라미터로 별도 등록되므로 clickableViews에는 넣지 않는다.
        let candidates: [UIView?] = [content.titleLabel,
                                     content.bodyLabel,
                                     content.ctaButton]
        let clickableViews: [UIView] = candidates.compactMap { $0 }

        nativeAdAssets.registerViewForInteraction(rootView: content,
                                                  mediaView: mediaView,
                                                  iconView: iconHolder,
                                                  clickableViews: clickableViews)

        // 광고에 없는 에셋(CTA/아이콘 등)의 필수 뷰를 숨긴다 — XIB placeholder가 그대로 남는 것을 방지.
        // Fyber 아이콘은 image가 아니라 appIcon "자식 뷰"로 채우므로 SDK 자동 판정 대신 직접 처리한다.
        content.hideEmptyViews(hidesIconWhenEmpty: false)
        content.iconImageView?.isHidden = !hasIconAsset
        return true
    }
}

extension FyberMediationUnifiedNativeAdView: IANativeAdDelegate {
    func iaParentViewController(forAdSpot adSpot: IANativeAdSpot?) -> UIViewController {
        return rootViewController ?? UIViewController()
    }
    
    func iaNativeAdDidReceiveClick(_ adSpot: IANativeAdSpot?, origin: String?) {
        delegate?.unifiedNativeClicked(message: "Fyber UnifiedNative clicked")
    }
    
    func iaNativeAdWillLogImpression(_ adSpot: IANativeAdSpot?) {
        delegate?.unifiedNativeImpression(message: "Fyber UnifiedNative impression")
    }
}
