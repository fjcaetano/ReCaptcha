//
//  ReCaptcha.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation
import WebKit


/** The public facade of ReCaptcha
*/
open class ReCaptcha: ReCaptchaWebViewManager {
    fileprivate struct Constants {
        struct InfoDictKeys {
            static let APIKey = "ReCaptchaKey"
            static let Domain = "ReCaptchaDomain"
        }
    }
    
    /** Initializes a ReCaptcha object
     
     Both `apiKey` and `baseURL` may be nil, in which case the lib will look for entries of `ReCaptchaKey` and 
     `ReCaptchaDomain`, respectively, in the project's Info.plist
     
     A key may be aquired here: https://www.google.com/recaptcha/admin#list
     
    - parameter apiKey: The API key to be provided to Google's ReCaptcha. Overrides the Info.plist entry.
    - parameter baseURL: A url domain to be load onto the webview. Overrides the Info.plist entry.
     
     - Throws:
        - `NSError.ReCaptchaCode.htmlLoadError` if is unable to load the HTML embedded in the bundle.
        - `NSError.ReCaptchaCode.apiKeyNotFound` if an `apiKey` is not provided and can't find one in the project's Info.plist.
        - `NSError.ReCaptchaCode.baseURLNotFound` if a `baseURL` is not provided and can't find one in the project's Info.plist.
        - Rethrows any exceptions thrown by `String(contentsOfFile:)`
    */
    public init(apiKey: String? = nil, baseURL: URL? = nil) throws {
        guard let filePath = Bundle(for: ReCaptcha.self).path(forResource: "recaptcha", ofType: "html") else {
            throw NSError(code: .htmlLoadError)
        }
        
        // Fetches from info.plist
        let infoDict = Bundle.main.infoDictionary
        
        guard let apiKey = apiKey ?? (infoDict?[Constants.InfoDictKeys.APIKey] as? String) else {
            throw NSError(code: .apiKeyNotFound)
        }
        
        guard let domain = infoDict?[Constants.InfoDictKeys.Domain] as? String, let baseURL = baseURL ?? URL(string: domain) else {
            throw NSError(code: .baseURLNotFound)
        }
        
        let rawHTML = try String(contentsOfFile: filePath)
        super.init(html: String(format: rawHTML, apiKey), apiKey: apiKey, baseURL: baseURL)
    }
}
