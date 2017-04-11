//
//  ReCaptcha+Rx.swift
//  Pods
//
//  Created by Flávio Caetano on 11/04/17.
//
//

import RxSwift


public extension Reactive where Base: ReCaptcha {
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
