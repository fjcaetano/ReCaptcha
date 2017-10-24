//
//  ReCaptcha+Rx.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 11/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import RxSwift
import UIKit

/// Makes ReCaptchaWebViewManager compatible with RxSwift extensions
extension ReCaptchaWebViewManager: ReactiveCompatible {}

/// Provides a public extension on ReCaptchaWebViewManager that makes it reactive.
public extension Reactive where Base: ReCaptchaWebViewManager {

    /**
     - parameter view: The view that should present the webview.
     
     Starts the challenge validation uppon subscription.

     The stream's element is a `Result<String, ReCaptchaError>` that may contain a valid token.

     Sends `stop()` uppon disposal.
     
     - See: `ReCaptchaWebViewManager.validate(on:completion:)`
     - See: `ReCaptchaWebViewManager.stop()`
     */
    func validate(on view: UIView) -> Observable<Base.Response> {
        return Observable<Base.Response>.create { [weak base] (observer: AnyObserver<Base.Response>) in
            base?.validate(on: view) { response in
                observer.onNext(response)
                observer.onCompleted()
            }

            return Disposables.create { [weak base] in
                base?.stop()
            }
        }
    }
}
