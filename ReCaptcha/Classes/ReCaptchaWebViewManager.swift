//
//  ReCaptchaWebViewManager.swift
//  Pods
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
    
    /// The view in which the webview may be presented.
    open weak var presenterView: UIView?
    
    
    fileprivate var completion: ((Response) -> Void)?
    fileprivate var configureWebView: ((WKWebView) -> Void)?
    fileprivate var decoder: ReCaptchaDecoder!
    fileprivate var didFinishLoading = false // webView.isLoading does not work in this case
    
    fileprivate lazy var webView: WKWebView = {
        let webview = WKWebView(frame: CGRect.zero, configuration: self.buildConfiguration())
        webview.navigationDelegate = self
        
        return webview
    }()
    
    
    /** Initializes the manager
     - parameters:
        - html: The HTML string to be loaded onto the webview
        - apiKey: The Google's ReCaptcha API Key
        - baseURL: The URL configured with the API Key
    */
    init(html: String, apiKey: String, baseURL: URL) {
        super.init()
        
        decoder = ReCaptchaDecoder { [weak self] result in
            self?.handle(result: result)
        }
        
        webView.loadHTMLString(String(format: html, apiKey), baseURL: baseURL)
    }
    
    
    /** Starts the challenge validation
     
    - parameter completion: A closure that receives a Result<String, NSError> which may contain a valid result token.
    */
    open func validate(completion: @escaping (Response) -> Void) {
        self.completion = completion
        
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
        
        presenterView?.addSubview(webView)
        
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
}
