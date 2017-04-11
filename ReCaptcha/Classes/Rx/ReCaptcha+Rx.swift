//
//  ReCaptcha+Rx.swift
//  Pods
//
//  Created by Flávio Caetano on 11/04/17.
//
//

import RxSwift


/** Provides a public extension on ReCaptcha that makes it reactive.
*/
public extension Reactive where Base: ReCaptcha {
    
    /** Starts the challenge validation uppon subscription.
     
    The stream's element is a `Result<String, NSError>` that may contain a valid token.
    
    - See:
     [ReCaptchaWebViewManager.validate](../Classes/ReCaptchaWebViewManager.html#/s:FC9ReCaptcha23ReCaptchaWebViewManager8validateFT10completionFGO6Result6ResultSSCSo7NSError_T__T_)
    */
    public func validate() -> Observable<Base.Response> {
        return Observable<Base.Response>.create { [weak base] (observer: AnyObserver<Base.Response>) in
            base?.validate { response in
                observer.onNext(response)
                observer.onCompleted()
            }
            
            return Disposables.create { [weak base] in
                base?.stop()
            }
        }
    }
}
