//
//  ReCaptchaError.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation

/// The codes of possible errors thrown by ReCaptcha
public enum ReCaptchaError: Error, CustomStringConvertible {
    /// Unexpected error
    case unexpected(Error)

    /// Could not load the HTML embedded in the bundle
    case htmlLoadError

    /// ReCaptchaKey was not provided
    case apiKeyNotFound

    /// ReCaptchaDomain was not provided
    case baseURLNotFound

    /// Received an unexpected message from javascript
    case wrongMessageFormat

    /// ReCaptcha setup failed
    case failedSetup

    /// ReCaptcha response expired
    case responseExpired

    /// ReCaptcha render failed
    case failedRender

    /// A human-readable description for each error
    public var description: String {
        switch self {
        case .unexpected(let error):
            return "Unexpected Error: \(error)"

        case .htmlLoadError:
            return "Could not load embedded HTML"

        case .apiKeyNotFound:
            return "ReCaptchaKey not provided"

        case .baseURLNotFound:
            return "ReCaptchaDomain not provided"

        case .wrongMessageFormat:
            return "Unexpected message from javascript"

        case .failedSetup:
            // swiftlint:disable line_length
            return """
            ⚠️ WARNING! ReCaptcha wasn't successfully configured. Please double check your ReCaptchaKey and ReCaptchaDomain.
            Also check that you're using ReCaptcha's **SITE KEY** for client side integration.
            """
            // swiftlint:enable line_length

        case .responseExpired:
            return "Response expired and need to re-verify"

        case .failedRender:
            return "Recaptha encountered an error in execution"
        }
    }
}
