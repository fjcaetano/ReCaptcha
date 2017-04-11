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


open class ReCaptchaWebViewManager: NSObject {
    public typealias Response = Result<String, NSError>
    
    fileprivate struct Constants {
        static let ExecuteJSCommand = "execute();"
    }
    
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
    
    
    init(html: String, apiKey: String, baseURL: URL) {
        super.init()
        
        decoder = ReCaptchaDecoder { [weak self] result in
            self?.handle(result: result)
        }
        
        webView.loadHTMLString(String(format: html, apiKey), baseURL: baseURL)
    }
    
    
    open func validate(completion: @escaping (Response) -> Void) {
        self.completion = completion
        
        execute()
    }
    
    
    open func stop() {
        webView.stopLoading()
    }
    
    
    open func configureWebView(_ configure: @escaping (WKWebView) -> Void) {
        self.configureWebView = configure
    }
}


// MARK: - Navigation
extension ReCaptchaWebViewManager: WKNavigationDelegate {
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
fileprivate extension ReCaptchaWebViewManager {
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
    
    func buildConfiguration() -> WKWebViewConfiguration {
        let controller = WKUserContentController()
        controller.add(decoder, name: "recaptcha")
        
        let conf = WKWebViewConfiguration()
        conf.userContentController = controller
        
        return conf
    }
    
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
