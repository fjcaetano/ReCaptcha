//
//  DispatchQueue__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 21/12/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha
import XCTest

class DispatchQueue__Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test__Throttle_Nil_Context() {
        // Execute closure called once
        let exp0 = expectation(description: "did call single closure")

        DispatchQueue.main.throttle(deadline: .now() + 0.1) {
            exp0.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Does not execute first closure
        let exp1 = expectation(description: "")
        DispatchQueue.main.throttle(deadline: .now() + 0.1) {
            XCTFail("Shouldn't be called")
        }

        DispatchQueue.main.throttle(deadline: .now() + 0.1) {
            exp1.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test__Throttle_Context() {
        // Execute closure called once
        let exp0 = expectation(description: "did call single closure")
        let c0 = UUID()

        DispatchQueue.main.throttle(deadline: .now() + 0.1, context: c0) {
            exp0.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Does not execute first closure
        let exp1 = expectation(description: "execute on valid context")
        let c1 = UUID()
        DispatchQueue.main.throttle(deadline: .now() + 0.1, context: c1) {
            XCTFail("Shouldn't be called")
        }

        DispatchQueue.main.throttle(deadline: .now() + 0.1, context: c1) {
            exp1.fulfill()
        }

        // Execute in a different context
        let exp2 = expectation(description: "execute on different context")
        let c2 = UUID()
        DispatchQueue.main.throttle(deadline: .now() + 0.1, context: c2) {
            exp2.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
