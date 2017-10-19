//
//  ViewController.swift
//  ReCaptcha
//
//  Created by fjcaetano on 03/22/2017.
//  Copyright (c) 2017 fjcaetano. All rights reserved.
//

import UIKit
import ReCaptcha
import Result
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    fileprivate static let webViewTag = 123
    
    fileprivate let recaptcha = try! ReCaptcha()
    fileprivate var disposeBag = DisposeBag()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = ViewController.webViewTag
        }
    }
    
    
    @IBAction func didPressButton(button: UIButton) {
        disposeBag = DisposeBag()

        let validate = recaptcha.rx.validate(on: view)
            .debug("validate")
            .share()
            
        let isLoading = validate
            .map { _ in false }
            .startWith(true)

        isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: disposeBag)

        isLoading
            .map { !$0 }
            .catchErrorJustReturn(false)
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
            
        validate
            .map { [weak self] _ in
                self?.view.viewWithTag(ViewController.webViewTag)
            }
            .subscribe(onNext: { subview in
                subview?.removeFromSuperview()
            })
            .disposed(by: disposeBag)
            
        validate
            .map { try $0.dematerialize() }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

