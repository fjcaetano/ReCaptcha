//
//  ReCaptchaWebViewManager__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import WebKit
import XCTest


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
        var result1: ReCaptchaResult?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView) { response in
            result1 = response
            exp1.fulfill()
        }

        waitForExpectations(timeout: 10)


        // Verify
        XCTAssertNotNil(result1)
        XCTAssertNil(result1?.error)
        XCTAssertEqual(result1?.token, apiKey)


        // Validate again
        let exp2 = expectation(description: "reload token")
        var result2: ReCaptchaResult?

        // Validate
        manager.validate(on: presenterView) { response in
            result2 = response
            exp2.fulfill()
        }

        waitForExpectations(timeout: 10)


        // Verify
        XCTAssertNotNil(result2)
        XCTAssertNil(result2?.error)
        XCTAssertEqual(result2?.token, apiKey)
    }


    func test__Validate__Show_ReCaptcha() {
        let exp = expectation(description: "show recaptcha")

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.configureWebView { _ in
            exp.fulfill()
        }

        manager.validate(on: presenterView) { _ in
            XCTFail("should not call completion")
        }

        waitForExpectations(timeout: 10)
    }


    func test__Validate__Message_Error() {
        var result: ReCaptchaResult?
        let exp = expectation(description: "message error")

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "\"foobar\"")
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView, resetOnError: false) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

        // Verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.error, .wrongMessageFormat)
        XCTAssertNil(result?.token)
    }

    func test__Validate__JS_Error() {
        var result: ReCaptchaResult?
        let exp = expectation(description: "js error")

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "foobar")
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView, resetOnError: false) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

        // Verify
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.error)
        XCTAssertNil(result?.token)

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
        manager.validate(on: presenterView) { _ in
            XCTFail("should not call completion")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func test__Configure_Web_View() {
        let exp = expectation(description: "configure webview")

        // Configure WebView
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.configureWebView { [unowned self] webView in
            XCTAssertEqual(webView.superview, self.presenterView)
            exp.fulfill()
        }

        manager.validate(on: presenterView) { _ in
            XCTFail("should not call completion")
        }

        waitForExpectations(timeout: 10)
    }

    func test__Configure_Web_View__Called_Once() {
        var count = 0
        let exp0 = expectation(description: "configure webview")

        // Configure WebView
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.configureWebView { _ in
            if count < 3 {
                manager.webView.evaluateJavaScript("execute();") { XCTAssertNil($1) }
            }

            count += 1
            exp0.fulfill()
        }

        manager.validate(on: presenterView) { _ in
            XCTFail("should not call completion")
        }

        waitForExpectations(timeout: 10)

        let exp1 = expectation(description: "waiting for extra calls")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: exp1.fulfill)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(count, 1)
    }

    func test__Configure_Web_View__Called_Again_With_Reset() {
        let exp0 = expectation(description: "configure webview 0")

        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.validate(on: presenterView) { _ in
            XCTFail("should not call completion")
        }

        // Configure Webview
        manager.configureWebView { _ in
            manager.webView.evaluateJavaScript("execute();") { XCTAssertNil($1) }
            exp0.fulfill()
        }

        waitForExpectations(timeout: 10)

        // Reset and ensure it calls again
        let exp1 = expectation(description: "configure webview 1")

        manager.configureWebView { _ in
            manager.webView.evaluateJavaScript("execute();") { XCTAssertNil($1) }
            exp1.fulfill()
        }

        manager.reset()
        waitForExpectations(timeout: 10)
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

        waitForExpectations(timeout: 10)
    }

    // MARK: Setup

    func test__Key_Setup() {
        let exp = expectation(description: "setup key")
        var result: ReCaptchaResult?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.token, apiKey)
    }

    func test__Endpoint_Setup() {
        let exp = expectation(description: "setup endpoint")
        let endpoint = ReCaptcha.Endpoint.alternate.getURL(locale: nil)
        var result: ReCaptchaResult?

        let manager = ReCaptchaWebViewManager(messageBody: "{token: endpoint}", endpoint: endpoint)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        manager.validate(on: presenterView) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.token, endpoint)
    }

    // MARK: Reset

    func test__Reset() {
        let exp1 = expectation(description: "fail on first execution")
        var result1: ReCaptchaResult?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey, shouldFail: true)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        // Error
        manager.validate(on: presenterView, resetOnError: false) { result in
            result1 = result
            exp1.fulfill()
        }

        waitForExpectations(timeout: 10)
        XCTAssertEqual(result1?.error, .wrongMessageFormat)

        // Resets and tries again
        let exp2 = expectation(description: "validates after reset")
        var result2: ReCaptchaResult?

        manager.reset()
        manager.validate(on: presenterView, resetOnError: false) { result in
            result2 = result
            exp2.fulfill()
        }

        waitForExpectations(timeout: 10)

        XCTAssertNil(result2?.error)
        XCTAssertEqual(result2?.token, apiKey)
    }

    func test__Validate__Reset_On_Error() {
        let exp = expectation(description: "fail on first execution")
        var result: ReCaptchaResult?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey, shouldFail: true)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        // Error
        manager.validate(on: presenterView, resetOnError: true) { response in
            result = response
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.token, apiKey)
    }

    func test__Validate__Should_Skip_For_Tests() {
        let exp = expectation(description: "did skip validation")

        let manager = ReCaptchaWebViewManager()
        manager.shouldSkipForTests = true

        manager.completion = { result in
            XCTAssertEqual(result.token, "")
            exp.fulfill()
        }

        manager.validate(on: presenterView)

        waitForExpectations(timeout: 1)
    }

    // MARK: Force Challenge Visible

    func test__Force_Visible_Challenge() {
        let manager = ReCaptchaWebViewManager()

        // Initial value
        XCTAssertFalse(manager.forceVisibleChallenge)

        // Set True
        manager.forceVisibleChallenge = true
        XCTAssertEqual(manager.webView.customUserAgent, "Googlebot/2.1")

        // Set False
        manager.forceVisibleChallenge = false
        XCTAssertNotEqual(manager.webView.customUserAgent?.isEmpty, false)
    }

    // MARK: On Did Finish Loading

    func test__Did_Finish_Loading__Immediate() {
        let exp = expectation(description: "did finish loading")

        let manager = ReCaptchaWebViewManager()

        /// Should call closure immediately since it's already loaded
        manager.onDidFinishLoading = {
            manager.onDidFinishLoading = exp.fulfill
        }

        waitForExpectations(timeout: 1)
    }

    func test__Did_Finish_Loading__Delayed() {
        let exp = expectation(description: "did finish loading")

        let manager = ReCaptchaWebViewManager(shouldFail: true)

        var called = false
        manager.onDidFinishLoading = {
            called = true
        }

        XCTAssertFalse(called)

        // Reset
        manager.onDidFinishLoading = exp.fulfill
        manager.reset()

        waitForExpectations(timeout: 3)
    }
}
