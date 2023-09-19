//
//  ReCaptcha.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
import WebKit


/**
*/
public class ReCaptcha {
    fileprivate struct Constants {
        struct InfoDictKeys {
            static let APIKey = "ReCaptchaKey"
            static let Domain = "ReCaptchaDomain"
        }
    }

    /// The JS API endpoint to be loaded onto the HTML file.
    public enum Endpoint {
        /** Google's default endpoint. Points to
         https://www.google.com/recaptcha/api.js
         */
        case `default`

        /// Alternate endpoint. Points to https://www.recaptcha.net/recaptcha/api.js
        case alternate

        internal func getURL(locale: Locale?) -> String {
            let localeAppendix = locale.map { "&hl=\($0.identifier)" } ?? ""
            switch self {
            case .default:
                return "https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit" + localeAppendix
            case .alternate:
                return "https://www.recaptcha.net/recaptcha/api.js?onload=onloadCallback&render=explicit"
                    + localeAppendix
            }
        }
    }

    /** Internal data model for CI in unit tests
     */
    struct Config {
        /// The raw unformated HTML file content
        let html: String

        /// The API key that will be sent to the ReCaptcha API
        let apiKey: String

        /// The base url to be used to resolve relative URLs in the webview
        let baseURL: URL

        /// The Bundle that holds ReCaptcha's assets
		private static let bundle: Bundle = Bundle.module

        /**
         - parameters:
             - apiKey: The API key sent to the ReCaptcha init
             - infoPlistKey: The API key retrived from the application's Info.plist
             - baseURL: The base URL sent to the ReCaptcha init
             - infoPlistURL: The base URL retrieved from the application's Info.plist

         - Throws: `ReCaptchaError.htmlLoadError`: if is unable to load the HTML embedded in the bundle.
         - Throws: `ReCaptchaError.apiKeyNotFound`: if an `apiKey` is not provided and can't find one in the project's
         Info.plist.
         - Throws: `ReCaptchaError.baseURLNotFound`: if a `baseURL` is not provided and can't find one in the project's
         Info.plist.
         - Throws: Rethrows any exceptions thrown by `String(contentsOfFile:)`
         */
        public init(apiKey: String?, infoPlistKey: String?, baseURL: URL?, infoPlistURL: URL?) throws {
            guard let filePath = Config.bundle.path(forResource: "recaptcha", ofType: "html") else {
                throw ReCaptchaError.htmlLoadError
            }

            guard let apiKey = apiKey ?? infoPlistKey else {
                throw ReCaptchaError.apiKeyNotFound
            }

            guard let domain = baseURL ?? infoPlistURL else {
                throw ReCaptchaError.baseURLNotFound
            }

            let rawHTML = try String(contentsOfFile: filePath)

            self.html = rawHTML
            self.apiKey = apiKey
            self.baseURL = Config.fixSchemeIfNeeded(for: domain)
        }
    }

    /// The worker that handles webview events and communication
    let manager: ReCaptchaWebViewManager

    /**
     - parameters:
         - apiKey: The API key sent to the ReCaptcha init
         - baseURL: The base URL sent to the ReCaptcha init
         - endpoint: The ReCaptcha endpoint to be used.
         - locale: A locale value to translate ReCaptcha into a different language
     
     Initializes a ReCaptcha object

     Both `apiKey` and `baseURL` may be nil, in which case the lib will look for entries of `ReCaptchaKey` and
     `ReCaptchaDomain`, respectively, in the project's Info.plist

     A key may be aquired here: https://www.google.com/recaptcha/admin#list

     - Throws: `ReCaptchaError.htmlLoadError`: if is unable to load the HTML embedded in the bundle.
     - Throws: `ReCaptchaError.apiKeyNotFound`: if an `apiKey` is not provided and can't find one in the project's
         Info.plist.
     - Throws: `ReCaptchaError.baseURLNotFound`: if a `baseURL` is not provided and can't find one in the project's
         Info.plist.
     - Throws: Rethrows any exceptions thrown by `String(contentsOfFile:)`
     */
    public convenience init(
        apiKey: String? = nil,
        baseURL: URL? = nil,
        endpoint: Endpoint = .default,
        locale: Locale? = nil
    ) throws {
        let infoDict = Bundle.main.infoDictionary

        let plistApiKey = infoDict?[Constants.InfoDictKeys.APIKey] as? String
        let plistDomain = (infoDict?[Constants.InfoDictKeys.Domain] as? String).flatMap(URL.init(string:))

        let config = try Config(apiKey: apiKey, infoPlistKey: plistApiKey, baseURL: baseURL, infoPlistURL: plistDomain)

        self.init(manager: ReCaptchaWebViewManager(
            html: config.html,
            apiKey: config.apiKey,
            baseURL: config.baseURL,
            endpoint: endpoint.getURL(locale: locale)
        ))
    }

    /**
     - parameter manager: A ReCaptchaWebViewManager instance.

      Initializes ReCaptcha with the given manager
    */
    init(manager: ReCaptchaWebViewManager) {
        self.manager = manager
    }

    /**
     - parameters:
         - view: The view that should present the webview.
         - resetOnError: If ReCaptcha should be reset if it errors. Defaults to `true`.
         - completion: A closure that receives a ReCaptchaResult which may contain a valid result token.

     Starts the challenge validation
    */
    public func validate(on view: UIView, resetOnError: Bool = true, completion: @escaping (ReCaptchaResult) -> Void) {
        manager.shouldResetOnError = resetOnError
        manager.completion = completion

        manager.validate(on: view)
    }


    /// Stops the execution of the webview
    public func stop() {
        manager.stop()
    }


    /**
     - parameter configure: A closure that receives an instance of `WKWebView` for configuration.

     Provides a closure to configure the webview for presentation if necessary.

     If presentation is required, the webview will already be a subview of `presenterView` if one is provided. Otherwise
     it might need to be added in a view currently visible.
    */
    public func configureWebView(_ configure: @escaping (WKWebView) -> Void) {
        manager.configureWebView = configure
    }

    /**
     Resets the ReCaptcha.

     The reset is achieved by calling `grecaptcha.reset()` on the JS API.
    */
    public func reset() {
        manager.reset()
    }

    /**
     - parameter closure: A closure that is called when the JS bundle finishes loading.

     Provides a closure to be notified when the webview finishes loading JS resources.

     The closure may be called multiple times since the resources may also be loaded multiple times
     in case of error or reset. This may also be immediately called if the resources have already
     finished loading when you set the closure.
    */
    public func didFinishLoading(_ closure: (() -> Void)?) {
        manager.onDidFinishLoading = closure
    }

    // MARK: - Development

#if DEBUG
    /// Forces the challenge widget to be explicitly displayed.
    public var forceVisibleChallenge: Bool {
        get { return manager.forceVisibleChallenge }
        set { manager.forceVisibleChallenge = newValue }
    }

    /**
     Allows validation stubbing for testing

     When this property is set to `true`, every call to `validate()` will immediately be resolved with `.token("")`.
     
     Use only when testing your application.
    */
    public var shouldSkipForTests: Bool {
        get { return manager.shouldSkipForTests }
        set { manager.shouldSkipForTests = newValue }
    }
#endif
}

// MARK: - Private Methods

private extension ReCaptcha.Config {
    /**
     - parameter url: The URL to be fixed
     - returns: An URL with scheme

     If the given URL has no scheme, prepends `http://` to it and return the fixed URL.
     */
    static func fixSchemeIfNeeded(for url: URL) -> URL {
        guard url.scheme?.isEmpty != false else {
            return url
        }

#if DEBUG
        print("⚠️ WARNING! Protocol not found for ReCaptcha domain (\(url))! You should add http:// or https:// to it!")
#endif

        if let fixedURL = URL(string: "http://" + url.absoluteString) {
            return fixedURL
        }

        return url
    }
}
