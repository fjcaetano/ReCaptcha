//
//  MainMenuPageObject.swift
//  ReCaptcha_UITests
//
//  Created by przemyslaw.wosko on 15/09/2018.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import XCTest

class MainMenuPageObject {

    private let queryProvider: XCUIElementTypeQueryProvider

    init(queryProvider: XCUIElementTypeQueryProvider) {
        self.queryProvider = queryProvider
    }

    var visibleChallengeSwitch: XCUIElement {
        return queryProvider.switches["VisibleChallengeSwitch"]
    }

    var skipForUITestsSwitch: XCUIElement {
        return queryProvider.switches["SkipUITestsSwitch"]
    }

    var validateButton: XCUIElement {
        return queryProvider.buttons["Validate"]
    }

    var alternateEndpointButton: XCUIElement {
        return queryProvider.segmentedControls.buttons["Alternate"]
    }

    var defaultEndpointButton: XCUIElement {
        return queryProvider.segmentedControls.buttons["Default Endpoint"]
    }

    var webview: XCUIElement {
        return queryProvider.staticTexts.element(matching: .any, identifier: "webview")
    }

}
