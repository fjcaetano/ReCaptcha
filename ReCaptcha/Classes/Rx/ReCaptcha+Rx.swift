//
//  ReCaptcha+Rx.swift
//  Pods
//
//  Created by Flávio Caetano on 11/04/17.
//
//

import RxSwift


/** Provides a public extension on ReCaptchaWebViewManager that makes it reactive.
*/
public extension Reactive where Base: ReCaptchaWebViewManager {
    
    /** Starts the challenge validation uppon subscription.
     
     The stream's element is a `Result<String, NSError>` that may contain a valid token.
     
     Sends `stop()` uppon disposal.
    
    - See:
     [ReCaptchaWebViewManager.validate(on:completion:)](../Classes/ReCaptchaWebViewManager.html#/s:FC9ReCaptcha23ReCaptchaWebViewManager8validateFT2onCSo6UIView10completionFGO6Result6ResultSSCSo7NSError_T__T_)
    */
    public func validate(on view: UIView) -> Observable<Base.Response> {
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
