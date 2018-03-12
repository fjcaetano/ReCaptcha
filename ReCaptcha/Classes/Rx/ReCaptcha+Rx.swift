//
//  ReCaptcha+Rx.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 11/04/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import RxSwift
import UIKit

/// Makes ReCaptcha compatible with RxSwift extensions
extension ReCaptcha: ReactiveCompatible {}

/// Provides a public extension on ReCaptcha that makes it reactive.
public extension Reactive where Base: ReCaptcha {

    /**
     - parameters:
        - view: The view that should present the webview.
        - resetOnError: If ReCaptcha should be reset if it errors. Defaults to `true`
     
     Starts the challenge validation uppon subscription.

     The stream's element is a String with the validation token.

     Sends `stop()` uppon disposal.
     
     - See: `ReCaptcha.validate(on:resetOnError:completion:)`
     - See: `ReCaptcha.stop()`
     */
    func validate(on view: UIView, resetOnError: Bool = true) -> Observable<String> {
        return Single<String>.create { [weak base] single in
            base?.validate(on: view, resetOnError: resetOnError) { result in
                switch result {
                case .token(let token):
                    single(.success(token))

                case .error(let error):
                    single(.error(error))
                }
            }

            return Disposables.create { [weak base] in
                base?.stop()
            }
        }
        .asObservable()
    }

    /**
     Resets the ReCaptcha.

     The reset is achieved by calling `grecaptcha.reset()` on the JS API.

     - See: `ReCaptcha.reset()`
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
