//
//  NSError+ReCaptcha.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation


fileprivate let kErrorDomain = "com.flaviocaetano.ReCaptcha"
extension NSError {
    enum Code: Int {
        case undefined
        case htmlLoadError
        case apiKeyNotFound
        case baseURLNotFound
        case wrongMessageFormat
    }
    
    
    var rc_code: Code? {
        return Code(rawValue: code)
    }
    
    
    convenience init(code: Code, userInfo: [AnyHashable: Any]? = nil) {
        self.init(domain: kErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
