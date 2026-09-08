//
//  FyberInitializationAdapter.swift
//  MediationFyber
//

import Foundation
import APSSPSDK
import IASDKCore

public final class FyberInitializationAdapter: APSSPInitializationProtocol {
    
    public init() { }
    
    public var sdkVersion: String? {
        let core = IASDKCore.sharedInstance()
        return core?.perform(NSSelectorFromString("version"))?.takeUnretainedValue() as? String
    }
    
    public func start(keys: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let appId = keys[APSSPInitKey.fyberAppId.key] else {
            completion(false, "appKey is nil")
            return
        }
        IASDKCore.sharedInstance().initWithAppID(appId)
        completion(true, nil)
//        IASDKCore.sharedInstance().initWithAppID("112191")
//        DTXLogger.setLogLevel(.debug)
    }
}
