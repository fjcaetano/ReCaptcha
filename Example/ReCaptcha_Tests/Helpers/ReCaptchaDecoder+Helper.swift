//
//  ReCaptchaDecoder+Helper.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/12/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
@testable import ReCaptcha
import WebKit

class MockMessage: WKScriptMessage {
    override var body: Any {
        return storedBody
    }

    fileprivate let storedBody: Any

    init(message: Any) {
        storedBody = message
    }
}

// MARK: - Decoder Helpers
extension ReCaptchaDecoder {
    func send(message: MockMessage) {
        userContentController(WKUserContentController(), didReceive: message)
    }
}

// MARK: - Result Helpers
extension ReCaptchaDecoder.Result: Equatable {
    var error: ReCaptchaError? {
        guard case .error(let error) = self else { return nil }
        return error
    }

    public static func == (lhs: ReCaptchaDecoder.Result, rhs: ReCaptchaDecoder.Result) -> Bool {
        switch (lhs, rhs) {
        case (.showReCaptcha, .showReCaptcha),
             (.didLoad, .didLoad):
            return true

        case (.token(let lht), .token(let rht)):
            return lht == rht

        case (.error(let lhe), .error(let rhe)):
            return lhe == rhe

        default:
            return false
        }
    }
}
