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
internal class ReCaptchaWebViewManager {

    fileprivate struct Constants {
        static let ExecuteJSCommand = "execute();"
        static let ResetCommand = "reset();"
        static let BotUserAgent = "Googlebot/2.1"
    }

#if DEBUG
    /// Forces the challenge to be explicitly displayed.
    var forceVisibleChallenge = false {
        didSet {
            // Also works on iOS < 9
            webView.performSelector(
                onMainThread: "_setCustomUserAgent:",
                with: forceVisibleChallenge ? Constants.BotUserAgent : nil,
                waitUntilDone: true
            )
        }
    }

    /// Allows validation stubbing for testing
    public var shouldSkipForTests = false
#endif

    /// Sends the result message
    var completion: ((ReCaptchaResult) -> Void)?

    /// Configures the webview for display when required
    var configureWebView: ((WKWebView) -> Void)?

    /// The dispatch token used to ensure `configureWebView` is only called once.
    var configureWebViewDispatchToken = UUID()

    /// If the ReCaptcha should be reset when it errors
    var shouldResetOnError = true

    /// The JS message recoder
    fileprivate var decoder: ReCaptchaDecoder!

    /// Indicates if the script has already been loaded by the `webView`
    fileprivate var didFinishLoading = false { // webView.isLoading does not work for WKWebview.loadHTMLString
        didSet {
            if didFinishLoading && completion != nil {
                // User has requested for validation
                // A small delay is necessary to allow JS to wrap its operations and avoid errors.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.execute()
                }
            }
        }
    }

    /// The observer for `.UIWindowDidBecomeVisible`
    fileprivate var observer: NSObjectProtocol?

    /// The observer for `\WKWebView.estimatedProgress`
    fileprivate var loadingObservation: NSKeyValueObservation?

    /// The endpoint url being used
    fileprivate var endpoint: String

    /// The webview that executes JS code
    lazy var webView: WKWebView = {
        let webview = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1, height: 1),
            configuration: self.buildConfiguration()
        )
        webview.accessibilityIdentifier = "webview"
        webview.accessibilityTraits = UIAccessibilityTraits.link
        webview.isHidden = true
        self.loadingObservation = webview.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            self?.didFinishLoading = change.newValue == 1
        }

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
                forName: UIWindow.didBecomeVisibleNotification,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let window = notification.object as? UIWindow else { return }
                self?.setupWebview(on: window, html: formattedHTML, url: baseURL)
            }
        }
    }

    /**
     - parameter view: The view that should present the webview.

     Starts the challenge validation
     */
     func validate(on view: UIView) {
#if DEBUG
        guard !shouldSkipForTests else {
            completion?(.token(""))
            return
        }
#endif
        webView.isHidden = false
        view.addSubview(webView)

        execute()
    }


    /// Stops the execution of the webview
    func stop() {
        webView.stopLoading()
    }

    /**
     Resets the ReCaptcha.

     The reset is achieved by calling `grecaptcha.reset()` on the JS API.
     */
    func reset() {
        didFinishLoading = false
        configureWebViewDispatchToken = UUID()

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
            if shouldResetOnError, let view = webView.superview {
                reset()
                validate(on: view)
            }
            else {
                completion?(.error(error))
            }

        case .showReCaptcha:
            DispatchQueue.once(token: configureWebViewDispatchToken) { [weak self] in
                guard let `self` = self else { return }
                self.configureWebView?(self.webView)
            }

        case .didLoad:
            // For testing purposes
            didFinishLoading = true

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
