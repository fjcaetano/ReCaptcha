//
//  DispatchQueue__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 21/12/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
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

    func test__Throttle() {
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
}
