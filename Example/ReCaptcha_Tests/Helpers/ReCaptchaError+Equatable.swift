//
//  ReCaptchaError+Equatable.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 16/10/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
@testable import ReCaptcha

extension ReCaptchaError: Equatable {
    public static func == (lhs: ReCaptchaError, rhs: ReCaptchaError) -> Bool {
        switch (lhs, rhs) {
        case (.htmlLoadError, .htmlLoadError),
             (.apiKeyNotFound, .apiKeyNotFound),
             (.baseURLNotFound, .baseURLNotFound),
             (.wrongMessageFormat, .wrongMessageFormat),
             (.failedSetup, .failedSetup),
             (.responseExpired, .responseExpired),
             (.failedRender, .failedRender):
            return true
        case (.unexpected(let lhe as NSError), .unexpected(let rhe as NSError)):
            return lhe == rhe
        default:
            return false
        }
    }

    static func random() -> ReCaptchaError {
        switch arc4random_uniform(7) {
        case 0: return .htmlLoadError
        case 1: return .apiKeyNotFound
        case 2: return .baseURLNotFound
        case 3: return .wrongMessageFormat
        case 4: return .failedSetup
        case 5: return .responseExpired
        case 6: return .failedRender
        default: return .unexpected(NSError())
        }
    }
}
