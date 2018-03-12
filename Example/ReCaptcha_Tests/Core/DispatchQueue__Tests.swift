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

    // MARK: Throttle

    func test__Throttle_Nil_Context() {
        // Execute closure called once
        let exp0 = expectation(description: "did call single closure")

        DispatchQueue.main.throttle(deadline: .now() + 0.1) {
            exp0.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Does not execute first closure
        let exp1 = expectation(description: "did call last closure")
        DispatchQueue.main.throttle(deadline: .now() + 0.1) {
            XCTFail("Shouldn't be called")
        }

        DispatchQueue.main.throttle(
            deadline: .now() + 0.1,
            action: exp1.fulfill
        )

        waitForExpectations(timeout: 1)
    }

    func test__Throttle_Context() {
        // Execute closure called once
        let exp0 = expectation(description: "did call single closure")
        let c0 = UUID()

        DispatchQueue.main.throttle(
            deadline: .now() + 0.1,
            context: c0,
            action: exp0.fulfill
        )

        waitForExpectations(timeout: 1)

        // Does not execute first closure
        let exp1 = expectation(description: "execute on valid context")
        let c1 = UUID()
        DispatchQueue.main.throttle(deadline: .now() + 0.1, context: c1) {
            XCTFail("Shouldn't be called")
        }

        DispatchQueue.main.throttle(
            deadline: .now() + 0.1,
            context: c1,
            action: exp1.fulfill
        )

        // Execute in a different context
        let exp2 = expectation(description: "execute on different context")
        let c2 = UUID()
        DispatchQueue.main.throttle(
            deadline: .now() + 0.1,
            context: c2,
            action: exp2.fulfill
        )

        waitForExpectations(timeout: 1)
    }

    // MARK: Debounce

    func test__Debounce_Nil_Context() {
        // Does not execute sequenced closures
        let exp0 = expectation(description: "did call first closure")

        DispatchQueue.main.debounce(
            interval: 0.1,
            action: exp0.fulfill
        )

        DispatchQueue.main.debounce(interval: 0) {
            XCTFail("Shouldn't be called")
        }

        waitForExpectations(timeout: 1)

        // Executes closure after previous has timed out
        let exp1 = expectation(description: "did call closure")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.main.debounce(
                interval: 0.1,
                action: exp1.fulfill
            )
        }

        waitForExpectations(timeout: 3)
    }

    func test__Debounce_Context() {
        // Does not execute sequenced closures
        let exp0 = expectation(description: "did call first closure")
        let c0 = UUID()

        DispatchQueue.main.debounce(
            interval: 0.1,
            context: c0,
            action: exp0.fulfill
        )

        DispatchQueue.main.debounce(interval: 0, context: c0) {
            XCTFail("Shouldn't be called")
        }

        // Execute in a different context
        let c1 = UUID()
        let exp1 = expectation(description: "executes in different context")
        DispatchQueue.main.debounce(
            interval: 0,
            context: c1,
            action: exp1.fulfill
        )

        waitForExpectations(timeout: 1)

        // Executes closure after previous has timed out
        let exp2 = expectation(description: "did call closure")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            DispatchQueue.main.debounce(
                interval: 0.1,
                context: c0,
                action: exp2.fulfill
            )
        }

        waitForExpectations(timeout: 5)
    }
}
