//
//  ReCaptchaError.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
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

    /// Received an unexpeted message from javascript
    case wrongMessageFormat


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
        }
    }
}
