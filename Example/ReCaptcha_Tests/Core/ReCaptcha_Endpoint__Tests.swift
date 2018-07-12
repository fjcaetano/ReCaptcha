//
//  ReCaptcha_Endpoint__.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 12/07/18.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha
import XCTest

class ReCaptcha_Endpoint__Tests: XCTestCase {

    private let endpoint = ReCaptcha.Endpoint.default
    private let endpointURL = "https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit"

    // MARK: - Locale

    func test__Locale__Nil() {
        XCTAssertEqual(endpoint.getURL(locale: nil), endpointURL)
    }

    func test__Locale__Valid() {
        let locale = Locale(identifier: "pt-BR")
        XCTAssertEqual(endpoint.getURL(locale: locale), "\(endpointURL)&hl=pt-BR")
    }
}
