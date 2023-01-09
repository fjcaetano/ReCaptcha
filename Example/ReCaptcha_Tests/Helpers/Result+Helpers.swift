//
//  Result+Helpers.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

extension ReCaptchaResult {
    var token: String? {
        guard case let .token(value) = self else { return nil }
        return value
    }

    var error: ReCaptchaError? {
        guard case let .error(error) = self else { return nil }
        return error
    }
}
