//
//  ViewController.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 03/22/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import ReCaptcha
import Result
import RxCocoa
import RxSwift
import UIKit


class ViewController: UIViewController {
    fileprivate static let webViewTag = 123

    // swiftlint:disable:next force_try
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
