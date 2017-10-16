//
//  ReCaptchaWebViewManager+Helpers.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

@testable import ReCaptcha

import Foundation


extension ReCaptchaWebViewManager {
    convenience init(messageBody: String, apiKey: String? = nil, endpoint: String? = nil) {
        let localhost = URL(string: "http://localhost")!
        let html = Bundle(for: ReCaptchaWebViewManager__Tests.self)
            .path(forResource: "mock", ofType: "html")
            .flatMap { try? String(contentsOfFile: $0) }
            .map { String(format: $0, arguments: ["message": messageBody]) }
        
        self.init(
            html: html!,
            apiKey: apiKey ?? String(arc4random()),
            baseURL: localhost,
            endpoint: endpoint ?? localhost.absoluteString
        )
    }
}
