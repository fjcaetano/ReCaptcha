//
//  ReCaptcha.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation
import WebKit


open class ReCaptcha: ReCaptchaWebViewManager {
    fileprivate struct Constants {
        struct InfoDictKeys {
            static let APIKey = "ReCaptchaKey"
            static let Domain = "ReCaptchaDomain"
        }
    }
    
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
