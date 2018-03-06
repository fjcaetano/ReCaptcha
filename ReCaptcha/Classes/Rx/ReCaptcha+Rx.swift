//
//  ReCaptcha+Rx.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 11/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import RxSwift
import UIKit

/// Makes ReCaptchaWebViewManager compatible with RxSwift extensions
extension ReCaptchaWebViewManager: ReactiveCompatible {}

/// Provides a public extension on ReCaptchaWebViewManager that makes it reactive.
public extension Reactive where Base: ReCaptchaWebViewManager {

    /**
     - parameters:
        - view: The view that should present the webview.
        - resetOnError: If ReCaptcha should be reset if it errors. Defaults to `true`
     
     Starts the challenge validation uppon subscription.

     The stream's element is a String with the validation token.

     Sends `stop()` uppon disposal.
     
     - See: `ReCaptchaWebViewManager.validate(on:resetOnError:completion:)`
     - See: `ReCaptchaWebViewManager.stop()`
     */
    func validate(on view: UIView, resetOnError: Bool = true) -> Observable<String> {
        return Observable<String>.create { [weak base] (observer: AnyObserver<String>) in
            base?.validate(on: view, resetOnError: resetOnError) { result in
                defer { observer.onCompleted() }

                switch result {
                case .token(let token):
                    observer.onNext(token)

                case .error(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create { [weak base] in
                base?.stop()
            }
        }
    }

    /**
     Resets the ReCaptcha.

     The reset is achieved by calling `grecaptcha.reset()` on the JS API.

     - See: `ReCaptchaWebViewManager.reset()`
     */
    var reset: AnyObserver<Void> {
        return AnyObserver { [weak base] event in
            guard case .next = event else {
                return
            }

            base?.reset()
        }
    }
}
