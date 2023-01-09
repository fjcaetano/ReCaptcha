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
        storedBody
    }

    fileprivate let storedBody: Any

    init(message: Any) {
        self.storedBody = message
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
        guard case let .error(error) = self else { return nil }
        return error
    }

    public static func == (lhs: ReCaptchaDecoder.Result, rhs: ReCaptchaDecoder.Result) -> Bool {
        switch (lhs, rhs) {
        case (.showReCaptcha, .showReCaptcha),
             (.didLoad, .didLoad):
            return true

        case let (.token(lht), .token(rht)):
            return lht == rht

        case let (.error(lhe), .error(rhe)):
            return lhe == rhe

        default:
            return false
        }
    }
}
