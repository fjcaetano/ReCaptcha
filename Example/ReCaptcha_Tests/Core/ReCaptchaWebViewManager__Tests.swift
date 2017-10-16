//
//  ReCaptchaWebViewManager__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
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
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey)
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
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
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
        let exp = expectation(description: "message error")
        
        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "\"foobar\"")
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
        XCTAssertEqual(result?.error, .wrongMessageFormat)
        XCTAssertNil(result?.value)
    }
    
    func test__Validate__JS_Error() {
        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "js error")
        
        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "foobar")
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
        XCTAssertNotNil(result?.error)
        XCTAssertNil(result?.value)

        switch result!.error! {
        case .unexpected(let error as NSError):
            XCTAssertEqual(error.code, WKError.javaScriptExceptionOccurred.rawValue)
        default:
            XCTFail("Unexpected error received")
        }
    }
    
    // MARK: Configure WebView
    
    func test__Configure_Web_View__Empty() {
        let exp = expectation(description: "configure webview")
        
        // Configure WebView
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.validate(on: presenterView) { response in
            XCTFail("should not call completion")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func test__Configure_Web_View() {
        let exp = expectation(description: "configure webview")
        
        // Configure WebView
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
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
        let exp = expectation(description: "stop loading")
        
        // Stop
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
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

    // MARK: Setup

    func test__Key_Setup() {
        let exp = expectation(description: "setup key")
        var result: ReCaptchaWebViewManager.Response?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.value, apiKey)
    }

    func test__Endpoint_Setup() {
        let exp = expectation(description: "setup endpoint")
        let endpoint = String(describing: arc4random())
        var result: ReCaptchaWebViewManager.Response?

        let manager = ReCaptchaWebViewManager(messageBody: "{token: endpoint}", endpoint: endpoint)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.value, endpoint)
    }
}
