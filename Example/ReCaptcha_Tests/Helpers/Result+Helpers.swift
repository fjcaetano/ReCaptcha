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
        guard case .token(let value) = self else { return nil }
        return value
    }

    var error: ReCaptchaError? {
        guard case .error(let error) = self else { return nil }
        return error
    }
}
