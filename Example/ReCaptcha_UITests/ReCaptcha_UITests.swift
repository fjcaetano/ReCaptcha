//
//  ReCaptcha_UITests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 16/01/18.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
@testable import ReCaptcha
@testable import ReCaptcha_Example
import XCTest

class ReCaptcha_UITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func test__Validate__Default_Endpoint() {
        let app = XCUIApplication()
        app.segmentedControls.buttons["Default Endpoint"].tap()
        app.switches["Switch"].tap()
        app.buttons["Validate"].tap()

        verifyValidation()
    }

    func test__Validate__Alternate_Endpoint() {
        let app = XCUIApplication()
        app.segmentedControls.buttons["Alternate"].tap()
        app.switches["Switch"].tap()
        app.buttons["Validate"].tap()

        verifyValidation()
    }

    // MARK: Private Methods

    private func verifyValidation() {
        let app = XCUIApplication()
        let webview = app.staticTexts.element(matching: .any, identifier: "webview")
        let webviewExists = webview.waitForExistence(timeout: 10)

        XCTAssertTrue(webviewExists)
    }
}
