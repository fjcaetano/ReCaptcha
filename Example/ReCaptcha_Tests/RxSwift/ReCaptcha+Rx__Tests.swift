//
//  ReCaptcha+Rx__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import XCTest
import RxSwift


class ReCaptcha_Rx__Tests: XCTestCase {
    
    fileprivate var disposeBag: DisposeBag!
    fileprivate var apiKey: String!
    fileprivate var presenterView: UIView!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        presenterView = UIApplication.shared.keyWindow!
        apiKey = String(arc4random())
    }
    
    override func tearDown() {
        disposeBag = nil
        presenterView = nil
        apiKey = nil
        
        super.tearDown()
    }
    
    
    func test__Validate__Token() {
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        
        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "validate token")
        
        // Validate
        manager.rx.validate(on: presenterView)
            .subscribe { event in
                switch event {
                case .next(let value):
                    result = value
                    
                case .error(let error):
                    XCTFail(error.localizedDescription)
                    
                case .completed:
                    exp.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 3)
        
        // Verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, apiKey)
        XCTAssertNil(result?.error)
    }
    
    
    func test__Validate__Show_ReCaptcha() {
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}", apiKey: apiKey)
        let exp = expectation(description: "show recaptcha")
        
        manager.configureWebView { _ in
            exp.fulfill()
        }
        
        // Validate
        manager.rx.validate(on: presenterView)
            .timeout(2, scheduler: MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(_):
                    XCTFail("should not have validated")
                    
                case .error(let error):
                    XCTAssertEqual(String(describing: error), RxError.timeout.debugDescription)
                    
                case .completed:
                    XCTFail("should not have completed")
                }
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 3)
    }
    
    
    func test__Validate__Error() {
        let manager = ReCaptchaWebViewManager(messageBody: "\"foobar\"", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        
        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "validate token")
        
        // Validate
        manager.rx.validate(on: presenterView)
            .subscribe { event in
                switch event {
                case .next(let value):
                    result = value
                    
                case .error(let error):
                    XCTFail(error.localizedDescription)
                    
                case .completed:
                    exp.fulfill()
                }
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 3)
        
        // Verify
        XCTAssertNotNil(result)
        XCTAssertNil(result?.value)
        XCTAssertNotNil(result?.error)
        XCTAssertEqual(result?.error, .wrongMessageFormat)
    }
    
    // MARK: Dispose
    
    func test__Dispose() {
        let exp = expectation(description: "stop loading")
        
        // Stop
        let manager = ReCaptchaWebViewManager(messageBody: "{action: \"showReCaptcha\"}")
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }
        
        let disposable = manager.rx.validate(on: presenterView)
            .subscribe { _ in
                XCTFail("should not validate")
            }
        disposable.dispose()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
