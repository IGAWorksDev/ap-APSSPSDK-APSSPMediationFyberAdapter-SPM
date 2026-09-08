//
//  APSSPNativeAd+Extension.swift
//  MediationFyber
//

import UIKit
import APSSPSDK

extension APSSPNativeAd {
    @objc public func bindFyberRenderer(renderer: APSSPFyberNativeAdRenderer) {
        if renderer.contentView == nil { renderer.contentView = renderer.nativeAdView }
        self.fyberRenderer = renderer
    }
}
