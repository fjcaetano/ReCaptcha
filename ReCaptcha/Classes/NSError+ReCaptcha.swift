//
//  NSError+ReCaptcha.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation

/// The domain for ReCaptcha's errors
let kReCaptchaErrorDomain = "com.flaviocaetano.ReCaptcha"

/** Adds enum codes to ReCaptcha's errors
 */
extension NSError {
    
    /** The codes of possible errors thrown by ReCaptcha
     
     - undefined: Any unexpected errors
     - htmlLoadError: Could not load the HTML embedded in the bundle
     - apiKeyNotFound: ReCaptchaKey was not provided
     - baseURLNotFound: ReCaptchaDomain was not provided
     - wrongMessageFormat: Received an unexpeted message from javascript
    */
    enum ReCaptchaCode: Int, CustomStringConvertible {
        /// Unexpected error
        case undefined
        
        /// Could not load the HTML embedded in the bundle
        case htmlLoadError
        
        /// ReCaptchaKey was not provided
        case apiKeyNotFound
        
        /// ReCaptchaDomain was not provided
        case baseURLNotFound
        
        /// Received an unexpeted message from javascript
        case wrongMessageFormat
        
        
        /// A human-readable description for each error
        var description: String {
            switch self {
            case .undefined:
                return "Unexpected Error"
                
            case .htmlLoadError:
                return "Could not load embedded HTML"
                
            case .apiKeyNotFound:
                return "ReCaptchaKey not provided"
                
            case .baseURLNotFound:
                return "ReCaptchaDomain not provided"
                
            case .wrongMessageFormat:
                return "Unexpected message from javascript"
            }
        }
    }
    
    
    /// The error ReCaptchaCode
    var rc_code: ReCaptchaCode? {
        guard domain == kReCaptchaErrorDomain else { return nil }
        return ReCaptchaCode(rawValue: code)
    }
    
    
    /** Initializes the error with a Code and an userInfo
    - parameter code: A ReCaptchaCode
    - parameter userInfo: The error's userInfo
    */
    convenience init(code: ReCaptchaCode, userInfo: [String: Any]? = nil) {
        var info = userInfo ?? [:]
        info[NSLocalizedDescriptionKey] = code.description
        
        self.init(domain: kReCaptchaErrorDomain, code: code.rawValue, userInfo: info)
    }
}
