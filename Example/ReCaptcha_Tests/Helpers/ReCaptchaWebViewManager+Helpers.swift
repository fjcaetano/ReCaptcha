//
//  ReCaptchaWebViewManager+Helpers.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
@testable import ReCaptcha
import WebKit

extension ReCaptchaWebViewManager {
    private static let unformattedHTML: String! = {
        Bundle(for: ReCaptchaWebViewManager__Tests.self)
            .path(forResource: "mock", ofType: "html")
            .flatMap { try? String(contentsOfFile: $0) }
    }()

    convenience init(
        messageBody: String = "",
        apiKey: String? = nil,
        endpoint: String? = nil,
        shouldFail: Bool = false
    ) {
        let localhost = URL(string: "http://localhost")!
        let html = String(format: ReCaptchaWebViewManager.unformattedHTML, arguments: [
            "message": messageBody,
            "shouldFail": shouldFail.description
        ])

        self.init(
            html: html,
            apiKey: apiKey ?? String(arc4random()),
            baseURL: localhost,
            endpoint: endpoint ?? localhost.absoluteString
        )
    }

    func configureWebView(_ configure: @escaping (WKWebView) -> Void) {
        configureWebView = configure
    }

    func validate(on view: UIView, resetOnError: Bool = true, completion: @escaping (ReCaptchaResult) -> Void) {
        self.shouldResetOnError = resetOnError
        self.completion = completion

        validate(on: view)
    }
}
