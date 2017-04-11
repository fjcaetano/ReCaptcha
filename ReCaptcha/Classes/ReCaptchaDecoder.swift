//
//  ReCaptchaDecoder.swift
//  Pods
//
//  Created by Flávio Caetano on 22/03/17.
//
//

import Foundation
import WebKit


/** The Decoder of javascript messages from the webview
*/
class ReCaptchaDecoder: NSObject {
    /** The decoder result.
     
     - token(String): A result token, if any
     - showReCaptcha: Indicates that the webview containing the challenge should be displayed.
     - error(NSError): Any errors
    */
    enum Result {
        /// A result token, if any
        case token(String)
        
        /// Indicates that the webview containing the challenge should be displayed.
        case showReCaptcha
        
        /// Any errors
        case error(NSError)
    }
    
    fileprivate let sendMessage: ((Result) -> Void)
    
    /** Initializes a decoder with a completion closure.
     - parameter didReceiveMessage: A closure that receives a ReCaptchaDecoder.Result
     */
    init(didReceiveMessage: @escaping (Result) -> Void) {
        sendMessage = didReceiveMessage
        
        super.init()
    }
    
    
    /** Sends an error to the completion closure
     - parameter error: The error to be sent.
    */
    func send(error: NSError) {
        sendMessage(.error(error))
    }
}


// MARK: Script Handler

/** Makes ReCaptchaDecoder conform to `WKScriptMessageHandler`
 */
extension ReCaptchaDecoder: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else {
            return sendMessage(.error(NSError(code: .wrongMessageFormat)))
        }
        
        sendMessage(Result.from(response: dict))
    }
}


// MARK: - Result

/** Private methods on `ReCaptchaDecoder.Result`
 */
fileprivate extension ReCaptchaDecoder.Result {
    
    /** Parses a dict received from the webview onto a `ReCaptchaDecoder.Result`
     - parameter response: A dictionary containing the message to be parsed
     - returns: A decoded ReCaptchaDecoder.Result
     */
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
