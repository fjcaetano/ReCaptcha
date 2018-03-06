//
//  ReCaptchaResult__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 06/03/18.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha
import XCTest


class ReCaptchaResult__Tests: XCTestCase {
    func test__Get_Token() {
        let token = UUID().uuidString
        let result = ReCaptchaResult.token(token)

        do {
            let value = try result.dematerialize()
            XCTAssertEqual(value, token)
        }
        catch let err {
            XCTFail(err.localizedDescription)
        }
    }

    func test__Get_Token__Error() {
        let error = ReCaptchaError.random()
        let result = ReCaptchaResult.error(error)

        do {
            _ = try result.dematerialize()
            XCTFail("Shouldn't have completed")
        }
        catch let err {
            XCTAssertEqual(err as? ReCaptchaError, error)
        }
    }
}
