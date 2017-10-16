//
//  ReCaptcha.swift
//  ReCaptcha
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

    /** The JS API endpoint to be loaded onto the HTML file.
     
     - default: Google's default endpoint. Points to https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit
     - alternate: Alternate endpoint. Points to https://www.recaptcha.net/recaptcha/api.js
     */
    public enum Endpoint {
        case `default`, alternate

        fileprivate var url: String {
            switch self {
            case .default: return "https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit"
            case .alternate: return "https://www.recaptcha.net/recaptcha/api.js"
            }
        }
    }

    /** Internal data model for DI in unit tests
    */
    struct Config {
        /// The raw unformated HTML file content
        let html: String

        // The API key that will be sent to the ReCaptcha API
        let apiKey: String

        // The base url to be used to resolve relative URLs in the webview
        let baseURL: URL

        /**
         - parameter apiKey: The API key sent to the ReCaptcha init
         - parameter infoPlistKey: The API key retrived from the application's Info.plist
         - parameter baseURL: The base URL sent to the ReCaptcha init
         - parameter infoPlistURL: The base URL retrieved from the application's Info.plist

         - Throws:
            - `NSError.ReCaptchaCode.htmlLoadError` if is unable to load the HTML embedded in the bundle.
            - `NSError.ReCaptchaCode.apiKeyNotFound` if an `apiKey` is not provided and can't find one in the project's Info.plist.
            - `NSError.ReCaptchaCode.baseURLNotFound` if a `baseURL` is not provided and can't find one in the project's Info.plist.
            - Rethrows any exceptions thrown by `String(contentsOfFile:)`
        */
        public init(apiKey: String?, infoPlistKey: String?, baseURL: URL?, infoPlistURL: URL?) throws {
            guard let bundlePath = Bundle(for: ReCaptcha.self).path(forResource: "ReCaptcha", ofType: "bundle"),
                let filePath = Bundle(path: bundlePath)?.path(forResource: "recaptcha", ofType: "html") else {
                    throw NSError(code: .htmlLoadError)
            }

            guard let apiKey = apiKey ?? infoPlistKey else {
                throw NSError(code: .apiKeyNotFound)
            }

            guard let domain = baseURL ?? infoPlistURL else {
                throw NSError(code: .baseURLNotFound)
            }

            let rawHTML = try String(contentsOfFile: filePath)
            
            self.html = rawHTML
            self.apiKey = apiKey
            self.baseURL = domain
        }
    }
    
    /** Initializes a ReCaptcha object
     
     Both `apiKey` and `baseURL` may be nil, in which case the lib will look for entries of `ReCaptchaKey` and 
     `ReCaptchaDomain`, respectively, in the project's Info.plist
     
     A key may be aquired here: https://www.google.com/recaptcha/admin#list
     
     - parameter apiKey: The API key to be provided to Google's ReCaptcha. Overrides the Info.plist entry. Defaults to `nil`.
     - parameter baseURL: A url domain to be load onto the webview. Overrides the Info.plist entry. Defaults to `nil`.
     - parameter endpoint: The JS API endpoint to be loaded onto the HTML file. Defaults to `.default`.
     
     - Throws:
        - `NSError.ReCaptchaCode.htmlLoadError` if is unable to load the HTML embedded in the bundle.
        - `NSError.ReCaptchaCode.apiKeyNotFound` if an `apiKey` is not provided and can't find one in the project's Info.plist.
        - `NSError.ReCaptchaCode.baseURLNotFound` if a `baseURL` is not provided and can't find one in the project's Info.plist.
        - Rethrows any exceptions thrown by `String(contentsOfFile:)`
    */
    public init(apiKey: String? = nil, baseURL: URL? = nil, endpoint: Endpoint = .default) throws {
        let infoDict = Bundle.main.infoDictionary

        let plistApiKey = infoDict?[Constants.InfoDictKeys.APIKey] as? String
        let plistDomain = (infoDict?[Constants.InfoDictKeys.Domain] as? String).flatMap(URL.init(string:))

        let config = try Config(apiKey: apiKey, infoPlistKey: plistApiKey, baseURL: baseURL, infoPlistURL: plistDomain)
        super.init(html: config.html, apiKey: config.apiKey, baseURL: config.baseURL, endpoint: endpoint.url)
    }
}
