//
//  ReCaptchaWebViewManager.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation
import WebKit
import Result


/** Handles comunications with the webview containing the ReCaptcha challenge.
*/
open class ReCaptchaWebViewManager: NSObject {
    public typealias Response = Result<String, NSError>
    
    fileprivate struct Constants {
        static let ExecuteJSCommand = "execute();"
    }
    
    
    fileprivate var completion: ((Response) -> Void)?
    fileprivate var configureWebView: ((WKWebView) -> Void)?
    fileprivate var decoder: ReCaptchaDecoder!
    fileprivate var didFinishLoading = false // webView.isLoading does not work in this case
    
    fileprivate lazy var webView: WKWebView = {
        let webview = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: self.buildConfiguration())
        webview.navigationDelegate = self
        webview.isHidden = true
        
        return webview
    }()
    
    /** Initializes the manager
     - parameters:
        - html: The HTML string to be loaded onto the webview
        - apiKey: The Google's ReCaptcha API Key
        - baseURL: The URL configured with the API Key
        - endpoint: The JS API endpoint to be loaded onto the HTML file.
    */
    init(html: String, apiKey: String, baseURL: URL, endpoint: String) {
        super.init()
        
        decoder = ReCaptchaDecoder { [weak self] result in
            self?.handle(result: result)
        }

        let formattedHTML = String(format: html, arguments: ["apiKey": apiKey, "endpoint": endpoint])

        if let window = UIApplication.shared.keyWindow {
            setupWebview(on: window, html: formattedHTML, url: baseURL)
        }
        else {
            NotificationCenter.default.addObserver(forName: .UIWindowDidBecomeVisible, object: nil, queue: nil)
            { [weak self] notification in
                guard let window = notification.object as? UIWindow else { return }
                self?.setupWebview(on: window, html: formattedHTML, url: baseURL)
            }
        }
    }
    
    
    /** Starts the challenge validation
     - parameters:
        - view: The view that presents the webview.
        - completion: A closure that receives a Result<String, NSError> which may contain a valid result token.
    */
    open func validate(on view: UIView, completion: @escaping (Response) -> Void) {
        self.completion = completion

        webView.isHidden = false
        webView.removeFromSuperview()
        view.addSubview(webView)

        execute()
    }
    
    
    /// Stops the execution of the webview
    open func stop() {
        webView.stopLoading()
    }
    
    
    /** Provides a closure to configure the webview for presentation if necessary.
     
    If presentation is required, the webview will already be a subview of `presenterView` if one is provided. Otherwise
    it might need to be added in a view currently visible.
    
    - parameter configure: A closure that receives an instance of `WKWebView` for configuration.
    */
    open func configureWebView(_ configure: @escaping (WKWebView) -> Void) {
        self.configureWebView = configure
    }
}


// MARK: - Navigation

/** Makes ReCaptchaWebViewManager conform to `WKNavigationDelegate`
 */
extension ReCaptchaWebViewManager: WKNavigationDelegate {
    /** Called when the navigation is complete.
     
     - parameter webView: The web view invoking the delegate method.
     - parameter navigation: The navigation object that finished.
     */
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishLoading = true
        
        if completion != nil {
            // User has requested for validation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.execute()
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
        
        webView.evaluateJavaScript(Constants.ExecuteJSCommand) { [weak self] result, error in
            if let error = error {
                self?.decoder.send(error: error as NSError)
            }
        }
    }
    
    /** Creates a `WKWebViewConfiguration` to be added to the `WKWebView` instance.
     - returns: An instance of `WKWebViewConfiguration`
     */
    func buildConfiguration() -> WKWebViewConfiguration {
        let controller = WKUserContentController()
        controller.add(decoder, name: "recaptcha")
        
        let conf = WKWebViewConfiguration()
        conf.userContentController = controller
        
        return conf
    }
    
    /** Handles the decoder results received from the webview
     - Parameter result: A `ReCaptchaDecoder.Result` with the decoded message.
     */
    func handle(result: ReCaptchaDecoder.Result) {
        switch result {
        case .token(let token):
            completion?(Response.success(token))
            
        case .error(let error):
            completion?(Response.failure(error))
            
        case .showReCaptcha:
            configureWebView?(webView)
        }
    }

    /** Adds the webview to a valid UIView and loads the initial HTML file
     - parameter window: The window in which to add the webview
     - parameter html: The embedded HTML file
     - parameter url: The base URL given to the webview
    */
    func setupWebview(on window: UIWindow, html: String, url: URL) {
        window.addSubview(webView)
        webView.loadHTMLString(html, baseURL: url)

        NotificationCenter.default.removeObserver(self)
    }
}
