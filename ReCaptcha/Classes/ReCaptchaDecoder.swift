//
//  ReCaptchaDecoder.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation
import WebKit


class ReCaptchaDecoder: NSObject {
    enum Result {
        case token(String)
        case showReCaptcha
        case error(NSError)
    }
    
    fileprivate let sendMessage: ((Result) -> Void)
    
    init(didReceiveMessage: @escaping (Result) -> Void) {
        sendMessage = didReceiveMessage
        
        super.init()
    }
    
    
    func send(error: NSError) {
        sendMessage(.error(error))
    }
}


// MARK: Script Handler
extension ReCaptchaDecoder: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else {
            return sendMessage(.error(NSError(code: .wrongMessageFormat)))
        }
        
        sendMessage(Result.from(response: dict))
    }
}


// MARK: - Result
fileprivate extension ReCaptchaDecoder.Result {
    static func from(response: [String: Any]) -> ReCaptchaDecoder.Result {
        if let token = response["token"] as? String {
            return .token(token)
        }
        
        if let action = response["action"] as? String, action == "showReCaptcha" {
            return .showReCaptcha
        }
        
        return .error(NSError(code: .undefined))
    }
}
