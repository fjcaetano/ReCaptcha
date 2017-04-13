//
//  ReCaptchaWebViewManager__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

@testable import ReCaptcha

import XCTest
import Result
import WebKit


class ReCaptchaWebViewManager__Tests: XCTestCase {
    
    fileprivate var apiKey: String!
    fileprivate var presenterView: UIView!
    
    override func setUp() {
        super.setUp()
        
        presenterView = UIApplication.shared.keyWindow!
        apiKey = String(arc4random())
    }
    
    override func tearDown() {
        presenterView = nil
        apiKey = nil
        
        super.tearDown()
    }
    
    // MARK: Validate
    
    func test__Validate__Token() {
        let exp1 = expectation(description: "load token")
        var result1: ReCaptchaWebViewManager.Response?
        
        // Validate
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "{token: key}"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        manager.validate(on: presenterView) { response in
            result1 = response
            exp1.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        
        // Verify
        XCTAssertNotNil(result1)
        XCTAssertNil(result1?.error)
        XCTAssertEqual(result1?.value, apiKey)
        
        
        // Validate again
        let exp2 = expectation(description: "reload token")
        var result2: ReCaptchaWebViewManager.Response?
        
        // Validate
        manager.validate(on: presenterView) { response in
            result2 = response
            exp2.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        
        // Verify
        XCTAssertNotNil(result2)
        XCTAssertNil(result2?.error)
        XCTAssertEqual(result2?.value, apiKey)
    }
    
    
    func test__Validate__Show_ReCaptcha() {
        let exp = expectation(description: "show recaptcha")
        
        // Validate
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "{action: \"showReCaptcha\"}"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.configureWebView { _ in
            exp.fulfill()
        }
        
        manager.validate(on: presenterView) { response in
            XCTFail("should not call completion")
        }
        
        waitForExpectations(timeout: 3)
    }
    
    
    func test__Validate__Message_Error() {
        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "show recaptcha")
        
        // Validate
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "\"foobar\""), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        // Verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.error?.rc_code, .wrongMessageFormat)
        XCTAssertNil(result?.value)
    }
    
    func test__Validate__JS_Error() {
        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "show recaptcha")
        
        // Validate
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "foobar"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        // Verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.error?.code, WKError.javaScriptExceptionOccurred.rawValue)
        XCTAssertNil(result?.value)
    }
    
    // MARK: Configure WebView
    
    func test__Configure_Web_View__Empty() {
        let exp = expectation(description: "show recaptcha")
        
        // Configure WebView
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "{action: \"showReCaptcha\"}"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.validate(on: presenterView) { response in
            XCTFail("should not call completion")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func test__Configure_Web_View() {
        let exp = expectation(description: "show recaptcha")
        
        // Configure WebView
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "{action: \"showReCaptcha\"}"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.configureWebView { [unowned self] webView in
            XCTAssertEqual(webView.superview, self.presenterView)
            exp.fulfill()
        }
        
        manager.validate(on: presenterView) { response in
            XCTFail("should not call completion")
        }
        
        waitForExpectations(timeout: 3)
    }
    
    // MARK: Stop
    
    func test__Stop() {
        let exp = expectation(description: "load token")
        
        // Stop
        let manager = ReCaptchaWebViewManager(html: loadHTML(with: "{token: key}"), apiKey: apiKey, baseURL: URL(string: "http://localhost")!)
        manager.stop()
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        manager.validate(on: presenterView) { _ in
            XCTFail("should not validate")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}


// MARK: - Private Methods
fileprivate extension ReCaptchaWebViewManager__Tests {
    func loadHTML(with messageBody: String) -> String {
        let htmlPath = Bundle(for: ReCaptchaWebViewManager__Tests.self).path(forResource: "mock", ofType: "html")
        return String(format: try! String(contentsOfFile: htmlPath!), "%@", messageBody)
    }
}


// MARK: - Result Helpers
extension Result {
    var value: T? {
        guard case .success(let value) = self else { return nil }
        return value
    }
    
    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
