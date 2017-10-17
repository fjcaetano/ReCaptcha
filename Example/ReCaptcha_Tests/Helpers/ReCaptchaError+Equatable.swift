//
//  ReCaptchaError+Equatable.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 16/10/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import Foundation

extension ReCaptchaError: Equatable {
    public static func ==(lhs: ReCaptchaError, rhs: ReCaptchaError) -> Bool {
        switch (lhs, rhs) {
            case (.htmlLoadError, .htmlLoadError),
                 (.apiKeyNotFound, .apiKeyNotFound),
                 (.baseURLNotFound, .baseURLNotFound),
                 (.wrongMessageFormat, .wrongMessageFormat):
            return true
        case (.unexpected(let lhe as NSError), .unexpected(let rhe as NSError)):
            return lhe == rhe
        default:
            return false
        }
    }

    static func random() -> ReCaptchaError {
        switch arc4random_uniform(4) {
        case 0: return .htmlLoadError
        case 1: return .apiKeyNotFound
        case 2: return .baseURLNotFound
        case 3: return .wrongMessageFormat
        default: return .unexpected(NSError())
        }
    }
}
