//
//  ReCaptcha+Rx__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import RxCocoa
import RxSwift
import XCTest


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

        waitForExpectations(timeout: 10)

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
                case .next:
                    XCTFail("should not have validated")

                case .error(let error):
                    XCTAssertEqual(String(describing: error), RxError.timeout.debugDescription)

                case .completed:
                    XCTFail("should not have completed")
                }
            }
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 10)
    }


    func test__Validate__Error() {
        let manager = ReCaptchaWebViewManager(messageBody: "\"foobar\"", apiKey: apiKey)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }


        var result: ReCaptchaWebViewManager.Response?
        let exp = expectation(description: "validate token")

        // Validate
        manager.rx.validate(on: presenterView, resetOnError: false)
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

        waitForExpectations(timeout: 10)

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

        waitForExpectations(timeout: 10)
    }

    // MARK: Reset

    func test__Reset() {
        let exp1 = expectation(description: "fail on first execution")
        let exp2 = expectation(description: "resets after failure")
        var result1: ReCaptchaWebViewManager.Response?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey, shouldFail: true)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        // Error
        let validate = manager.rx.validate(on: presenterView, resetOnError: false)
            .share(replay: 1)

        validate
            .subscribe { event in
                switch event {
                case .next(let value):
                    result1 = value

                case .error(let error):
                    XCTFail(error.localizedDescription)

                case .completed:
                    exp1.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // Resets after failure
        validate
            .flatMap { result -> Observable<Void> in
                switch result {
                case .failure: return .just(())
                default: return .empty()
                }
            }
            .take(1)
            .do(onCompleted: exp2.fulfill)
            .bind(to: manager.rx.reset)
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 10)
        XCTAssertEqual(result1?.error, .wrongMessageFormat)

        // Resets and tries again
        let exp3 = expectation(description: "validates after reset")
        var result2: ReCaptchaWebViewManager.Response?

        manager.rx.validate(on: presenterView, resetOnError: false)
            .subscribe { event in
                switch event {
                case .next(let value):
                    result2 = value

                case .error(let error):
                    XCTFail(error.localizedDescription)

                case .completed:
                    exp3.fulfill()
                }
            }
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 10)
        XCTAssertEqual(result2?.value, apiKey)
    }

    func test__Validate__Reset_On_Error() {
        let exp = expectation(description: "executes after failure on first execution")
        var result: ReCaptchaWebViewManager.Response?

        // Validate
        let manager = ReCaptchaWebViewManager(messageBody: "{token: key}", apiKey: apiKey, shouldFail: true)
        manager.configureWebView { _ in
            XCTFail("should not ask to configure the webview")
        }

        // Error
        manager.rx.validate(on: presenterView, resetOnError: true)
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

        waitForExpectations(timeout: 10)
        XCTAssertEqual(result?.value, apiKey)
    }
}
