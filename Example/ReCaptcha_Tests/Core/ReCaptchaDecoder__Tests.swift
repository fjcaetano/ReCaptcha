//
//  ReCaptchaDecoder__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import WebKit
import XCTest


class ReCaptchaDecoder__Tests: XCTestCase {
    fileprivate typealias Result = ReCaptchaDecoder.Result

    fileprivate var assertResult: ((Result) -> Void)?
    fileprivate var decoder: ReCaptchaDecoder!

    override func setUp() {
        super.setUp()

        decoder = ReCaptchaDecoder { [weak self] result in
            self?.assertResult?(result)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func test__Send_Error() {
        let exp = expectation(description: "send error message")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let err = ReCaptchaError.random()
        decoder.send(error: err)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertNotNil(result)
        XCTAssertEqual(result, .error(err))
    }


    func test__Decode__Wrong_Format() {
        let exp = expectation(description: "send unsupported message")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let message = MockMessage(message: "foobar")
        decoder.send(message: message)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertEqual(result, .error(ReCaptchaError.wrongMessageFormat))
    }


    func test__Decode__Unexpected_Action() {
        let exp = expectation(description: "send message with unexpected action")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let message = MockMessage(message: ["action": "bar"])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertEqual(result, .error(ReCaptchaError.wrongMessageFormat))
    }


    func test__Decode__ShowReCaptcha() {
        let exp = expectation(description: "send showReCaptcha message")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let message = MockMessage(message: ["action": "showReCaptcha"])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertEqual(result, .showReCaptcha)
    }


    func test__Decode__Token() {
        let exp = expectation(description: "send token message")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let token = String(arc4random())
        let message = MockMessage(message: ["token": token])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertEqual(result, .token(token))
    }


    func test__Decode__DidLoad() {
        let exp = expectation(description: "send did load message")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }


        // Send
        let message = MockMessage(message: ["action": "didLoad"])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)


        // Check
        XCTAssertEqual(result, .didLoad)
    }

    func test__Decode__Error_Setup_Failed() {
        let exp = expectation(description: "send error")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }

        // Send
        let message = MockMessage(message: ["error": 27])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)

        // Check
        XCTAssertEqual(result, .error(.failedSetup))
    }

    func test__Decode__Error_Response_Expired() {
        let exp = expectation(description: "send error")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }

        // Send
        let message = MockMessage(message: ["error": 28])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)

        // Check
        XCTAssertEqual(result, .error(.responseExpired))
    }

    func test__Decode__Error_Render_Failed() {
        let exp = expectation(description: "send error")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }

        // Send
        let message = MockMessage(message: ["error": 29])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)

        // Check
        XCTAssertEqual(result, .error(.failedRender))
    }

    func test__Decode__Error_Wrong_Format() {
        let exp = expectation(description: "send error")
        var result: Result?

        assertResult = { res in
            result = res
            exp.fulfill()
        }

        // Send
        let message = MockMessage(message: ["error": 26])
        decoder.send(message: message)

        waitForExpectations(timeout: 1)

        // Check
        XCTAssertEqual(result, .error(.wrongMessageFormat))
    }
}
