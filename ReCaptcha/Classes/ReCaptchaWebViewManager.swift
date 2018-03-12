//
//  ReCaptchaWebViewManager.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
import WebKit


/** Handles comunications with the webview containing the ReCaptcha challenge.
 */
open class ReCaptchaWebViewManager {
    /** The `webView` delegate object that performs execution uppon script loading
     */
    fileprivate class WebViewDelegate: NSObject, WKNavigationDelegate {
        struct Constants {
            /// The host that loaded requests should have
            static let apiURLHost = "www.google.com"
        }

        /// The parent manager
        private weak var manager: ReCaptchaWebViewManager?

        /// The active requests' urls
        private var activeRequests = Set<String>(minimumCapacity: 0)

        /// - parameter manager: The parent manager
        init(manager: ReCaptchaWebViewManager) {
            self.manager = manager
        }

        /**
         - parameters:
             - webView: The web view invoking the delegate method.
             - navigationAction: Descriptive information about the action triggering the navigation request.
             - decisionHandler: The decision handler to call to allow or cancel the navigation. The argument is one of
         the constants of the enumerated type WKNavigationActionPolicy.

         Decides whether to allow or cancel a navigation.
         */
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy
        ) -> Void) {
            defer { decisionHandler(.allow) }

            if let url = navigationAction.request.url, url.host == Constants.apiURLHost {
                activeRequests.insert(url.absoluteString)
            }
        }

        /**
         - parameters:
            - webView: The web view invoking the delegate method.
            - navigationResponse: Descriptive information about the navigation response.
            - decisionHandler: A block to be called when your app has decided whether to allow or cancel the navigation

         Decides whether to allow or cancel a navigation after its response is known.
         */
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationResponse: WKNavigationResponse,
            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
        ) {
            defer { decisionHandler(.allow) }
            guard let url = navigationResponse.response.url?.absoluteString,
                activeRequests.remove(url) != nil, activeRequests.isEmpty else {
                    return
            }

            execute()
        }

        /// Flag the requests as finished and call ReCaptcha execution if necessary
        func execute() {
            guard manager?.didFinishLoading != true else { return }

            DispatchQueue.main.throttle(deadline: .now() + 1, context: self) { [weak self] in
                // Did finish loading the ReCaptcha JS source
                self?.manager?.didFinishLoading = true

                if self?.manager?.completion != nil {
                    // User has requested for validation
                    self?.manager?.execute()
                }
            }
        }
    }

    fileprivate struct Constants {
        static let ExecuteJSCommand = "execute();"
        static let ResetCommand = "reset();"
        static let BotUserAgent = "Googlebot/2.1"
    }

#if DEBUG
    /// Forces the challenge to be explicitly displayed.
    public var forceVisibleChallenge = false {
        didSet {
            // Also works on iOS < 9
            webView.performSelector(
                onMainThread: "_setCustomUserAgent:",
                with: forceVisibleChallenge ? Constants.BotUserAgent : nil,
                waitUntilDone: true
            )
        }
    }
#endif

    /// Sends the result message
    fileprivate var completion: ((ReCaptchaResult) -> Void)?

    /// Configures the webview for display when required
    fileprivate var configureWebView: ((WKWebView) -> Void)?

    /// The JS message recoder
    fileprivate var decoder: ReCaptchaDecoder!

    /// Indicates if the script has already been loaded by the `webView`
    fileprivate var didFinishLoading = false // webView.isLoading does not work in this case

    /// The observer for `.UIWindowDidBecomeVisible`
    fileprivate var observer: NSObjectProtocol?

    /// The endpoint url being used
    fileprivate var endpoint: String

    /// If the ReCaptcha should be reset when it errors
    fileprivate var shouldResetOnError = true

    /// The `webView` delegate implementation
    fileprivate lazy var webviewDelegate: WebViewDelegate = {
        WebViewDelegate(manager: self)
    }()

    /// The webview that executes JS code
    lazy var webView: WKWebView = {
        let webview = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1, height: 1),
            configuration: self.buildConfiguration()
        )
        webview.navigationDelegate = self.webviewDelegate
        webview.accessibilityIdentifier = "webview"
        webview.accessibilityTraits = UIAccessibilityTraitLink
        webview.isHidden = true

        return webview
    }()

    /**
     - parameters:
         - html: The HTML string to be loaded onto the webview
         - apiKey: The Google's ReCaptcha API Key
         - baseURL: The URL configured with the API Key
         - endpoint: The JS API endpoint to be loaded onto the HTML file.
     */
    init(html: String, apiKey: String, baseURL: URL, endpoint: String) {
        self.endpoint = endpoint
        self.decoder = ReCaptchaDecoder { [weak self] result in
            self?.handle(result: result)
        }

        let formattedHTML = String(format: html, arguments: ["apiKey": apiKey, "endpoint": endpoint])

        if let window = UIApplication.shared.keyWindow {
            setupWebview(on: window, html: formattedHTML, url: baseURL)
        }
        else {
            observer = NotificationCenter.default.addObserver(
                forName: .UIWindowDidBecomeVisible,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let window = notification.object as? UIWindow else { return }
                self?.setupWebview(on: window, html: formattedHTML, url: baseURL)
            }
        }
    }


    /**
     - parameters:
        - view: The view that should present the webview.
        - resetOnError: If ReCaptcha should be reset if it errors. Defaults to `true`.
        - completion: A closure that receives a ReCaptchaResult which may contain a valid result token.

     Starts the challenge validation
     */
    open func validate(on view: UIView, resetOnError: Bool = true, completion: @escaping (ReCaptchaResult) -> Void) {
        self.completion = completion
        self.shouldResetOnError = resetOnError

        webView.isHidden = false
        view.addSubview(webView)

        execute()
    }


    /// Stops the execution of the webview
    open func stop() {
        webView.stopLoading()
    }


    /**
     - parameter configure: A closure that receives an instance of `WKWebView` for configuration.

     Provides a closure to configure the webview for presentation if necessary.

     If presentation is required, the webview will already be a subview of `presenterView` if one is provided. Otherwise
     it might need to be added in a view currently visible.
     */
    open func configureWebView(_ configure: @escaping (WKWebView) -> Void) {
        self.configureWebView = configure
    }

    /**
     Resets the ReCaptcha.

     The reset is achieved by calling `grecaptcha.reset()` on the JS API.
     */
    open func reset() {
        didFinishLoading = false

        webView.evaluateJavaScript(Constants.ResetCommand) { [weak self] _, error in
            if let error = error {
                self?.decoder.send(error: .unexpected(error))
            }
        }
    }
}

// MARK: - Private Methods

/** Private methods for ReCaptchaWebViewManager
 */
fileprivate extension ReCaptchaWebViewManager {

    /** Executes the JS command that loads the ReCaptcha challenge.
     This method has no effect if the webview hasn't finished loading.
     */
    func execute() {
        guard didFinishLoading else {
            // Hasn't finished loading the HTML yet
            return
        }

        webView.evaluateJavaScript(Constants.ExecuteJSCommand) { [weak self] _, error in
            if let error = error {
                self?.decoder.send(error: .unexpected(error))
            }
        }
    }

    /**
     - returns: An instance of `WKWebViewConfiguration`

     Creates a `WKWebViewConfiguration` to be added to the `WKWebView` instance.
     */
    func buildConfiguration() -> WKWebViewConfiguration {
        let controller = WKUserContentController()
        controller.add(decoder, name: "recaptcha")

        let conf = WKWebViewConfiguration()
        conf.userContentController = controller

        return conf
    }

    /**
     - parameter result: A `ReCaptchaDecoder.Result` with the decoded message.

     Handles the decoder results received from the webview
     */
    func handle(result: ReCaptchaDecoder.Result) {
        switch result {
        case .token(let token):
            completion?(.token(token))

        case .error(let error):
            if shouldResetOnError, let view = webView.superview, let completion = completion {
                reset()
                validate(on: view, completion: completion)
            }
            else {
                completion?(.error(error))
            }

        case .showReCaptcha:
            // Ensures `configureWebView` won't get called multiple times in a short period
            DispatchQueue.main.debounce(interval: 1) { [weak self] in
                guard let `self` = self else { return }
                self.configureWebView?(self.webView)
            }

        case .didLoad:
            // For testing purposes
            webviewDelegate.execute()

        case .log(let message):
            #if DEBUG
            print("[JS LOG]:", message)
            #endif
        }
    }

    /**
     - parameters:
         - window: The window in which to add the webview
         - html: The embedded HTML file
         - url: The base URL given to the webview

     Adds the webview to a valid UIView and loads the initial HTML file
     */
    func setupWebview(on window: UIWindow, html: String, url: URL) {
        window.addSubview(webView)
        webView.loadHTMLString(html, baseURL: url)

        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
