//
//  ReCaptchaDecoder.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 22/03/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import Foundation
import WebKit


/** The Decoder of javascript messages from the webview
 */
internal class ReCaptchaDecoder: NSObject {
    /** The decoder result.
     */
    enum Result {
        /// A result token, if any
        case token(String)

        /// Indicates that the webview containing the challenge should be displayed.
        case showReCaptcha

        /// Any errors
        case error(ReCaptchaError)

        /// Did finish loading resources
        case didLoad

        /// Logs a string onto the console
        case log(String)
    }

    /// The closure that receives messages
    fileprivate let sendMessage: ((Result) -> Void)

    /**
     - parameter didReceiveMessage: A closure that receives a ReCaptchaDecoder.Result

     Initializes a decoder with a completion closure.
     */
    init(didReceiveMessage: @escaping (Result) -> Void) {
        sendMessage = didReceiveMessage

        super.init()
    }


    /**
     - parameter error: The error to be sent.

     Sends an error to the completion closure
     */
    func send(error: ReCaptchaError) {
        sendMessage(.error(error))
    }
}


// MARK: Script Handler

/** Makes ReCaptchaDecoder conform to `WKScriptMessageHandler`
 */
extension ReCaptchaDecoder: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else {
            return sendMessage(.error(.wrongMessageFormat))
        }

        sendMessage(Result.from(response: dict))
    }
}


// MARK: - Result

/** Private methods on `ReCaptchaDecoder.Result`
 */
fileprivate extension ReCaptchaDecoder.Result {

    /**
     - parameter response: A dictionary containing the message to be parsed
     - returns: A decoded ReCaptchaDecoder.Result

     Parses a dict received from the webview onto a `ReCaptchaDecoder.Result`
     */
    static func from(response: [String: Any]) -> ReCaptchaDecoder.Result {
        if let token = response["token"] as? String {
            return .token(token)
        }
        else if let message = response["log"] as? String {
            return .log(message)
        }
        else if (response["error"] as? Int) != nil {
            return .error(.failedSetup)
        }

        if let action = response["action"] as? String {
            switch action {
            case "showReCaptcha":
                return .showReCaptcha

            case "didLoad":
                return .didLoad

            default:
                break
            }
        }

        if let message = response["log"] as? String {
            return .log(message)
        }

        return .error(.wrongMessageFormat)
    }
}
