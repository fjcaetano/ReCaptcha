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

    var app: XCUIApplication!
    var mainMenu: MainMenuPageObject!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        mainMenu = MainMenuPageObject(queryProvider: app)
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func test__Validate__Default_Endpoint() {
        mainMenu.defaultEndpointButton.tap()
        mainMenu.visibleChallengeSwitch.tap()
        mainMenu.validateButton.tap()

        XCTAssertTrue(mainMenu.webview.waitForExistence(timeout: 10))
    }

    func test__Validate__Alternate_Endpoint() {
        mainMenu.alternateEndpointButton.tap()
        mainMenu.visibleChallengeSwitch.tap()
        mainMenu.validateButton.tap()

        XCTAssertTrue(mainMenu.webview.waitForExistence(timeout: 10))
    }

    func test_Validate_skipForUITestsFlag() {
        mainMenu.skipForUITestsSwitch.tap()
        mainMenu.validateButton.tap()

        XCTAssertFalse(mainMenu.webview.waitForExistence(timeout: 5))
    }

}
