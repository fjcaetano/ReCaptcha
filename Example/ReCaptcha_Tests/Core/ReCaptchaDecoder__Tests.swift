//
//  ReCaptchaDecoder__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import XCTest
import WebKit


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
        let exp = expectation(description: "send message")
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
        XCTAssertEqual(result?.error, err)
        XCTAssertNil(result?.token)
        XCTAssertFalse(result!.showReCaptcha)
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
        XCTAssertEqual(result?.error, .wrongMessageFormat)
        XCTAssertNil(result?.token)
        XCTAssertFalse(result!.showReCaptcha)
    }
    
    
    func test__Decode__Undefined() {
        let exp = expectation(description: "send message with undefined body")
        var result: Result?
        
        assertResult = { res in
            result = res
            exp.fulfill()
        }
        
        
        // Send
        let message = MockMessage(message: ["foo": "bar"])
        decoder.send(message: message)
        
        waitForExpectations(timeout: 1)
        
        
        // Check
        XCTAssertEqual(result?.error, .wrongMessageFormat)
        XCTAssertNil(result?.token)
        XCTAssertFalse(result!.showReCaptcha)
    }
    
    
    func test__Decode__ShowReCaptcha() {
        let exp = expectation(description: "send message with undefined body")
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
        XCTAssertNil(result?.error)
        XCTAssertNil(result?.token)
        XCTAssertTrue(result!.showReCaptcha)
    }
    
    
    func test__Decode__Token() {
        let exp = expectation(description: "send message with undefined body")
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
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.token, token)
        XCTAssertFalse(result!.showReCaptcha)
    }
}


class MockMessage: WKScriptMessage {
    override var body: Any {
        return storedBody
    }
    
    fileprivate let storedBody: Any
    
    init(message: Any) {
        storedBody = message
    }
}


// MARK: - Decoder Helpers
fileprivate extension ReCaptchaDecoder {
    func send(message: MockMessage) {
        userContentController(WKUserContentController(), didReceive: message)
    }
}


// MARK: - Result Helpers
extension ReCaptchaDecoder.Result {
    var token: String? {
        guard case .token(let token) = self else { return nil }
        return token
    }
    
    var showReCaptcha: Bool {
        guard case .showReCaptcha = self else { return false }
        return true
    }
    
    var error: ReCaptchaError? {
        guard case .error(let error) = self else { return nil }
        return error
    }
}
