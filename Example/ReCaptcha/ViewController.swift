//
//  ViewController.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 03/22/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import ReCaptcha
import RxCocoa
import RxSwift
import UIKit


class ViewController: UIViewController {
    private struct Constants {
        static let webViewTag = 123
        static let testLabelTag = 321
    }

    private var recaptcha: ReCaptcha!
    private var disposeBag = DisposeBag()

    private var locale: Locale?
    private var endpoint = ReCaptcha.Endpoint.default

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var localeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var endpointSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var visibleChallengeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupReCaptcha()
    }

    @IBAction func didPressEndpointSegmentedControl(_ sender: UISegmentedControl) {
        label.text = ""
        switch sender.selectedSegmentIndex {
        case 0: endpoint = .default
        case 1: endpoint = .alternate
        default: assertionFailure("invalid index")
        }

        setupReCaptcha()
    }

    @IBAction func didPressLocaleSegmentedControl(_ sender: UISegmentedControl) {
        label.text = ""
        switch sender.selectedSegmentIndex {
        case 0: locale = nil
        case 1: locale = Locale(identifier: "zh-CN")
        default: assertionFailure("invalid index")
        }

        setupReCaptcha()
    }

    @IBAction private func didPressButton(button: UIButton) {
        disposeBag = DisposeBag()

        recaptcha.rx.didFinishLoading
            .debug("did finish loading")
            .subscribe()
            .disposed(by: disposeBag)

        let validate = recaptcha.rx.validate(on: view, resetOnError: false)
            .catch { error in
                return .just("Error \(error)")
            }
            .debug("validate")
            .share()

        let isLoading = validate
            .map { _ in false }
            .startWith(true)
            .share(replay: 1)

        isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: disposeBag)

        let isEnabled = isLoading
            .map { !$0 }
            .catchAndReturn(false)
            .share(replay: 1)

        isEnabled
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)

        isEnabled
            .bind(to: endpointSegmentedControl.rx.isEnabled)
            .disposed(by: disposeBag)

        validate
            .map { [weak self] _ in
                self?.view.viewWithTag(Constants.webViewTag)
            }
            .subscribe(onNext: { subview in
                subview?.removeFromSuperview()
            })
            .disposed(by: disposeBag)

        validate
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        visibleChallengeSwitch.rx.value
            .subscribe(onNext: { [weak recaptcha] value in
                recaptcha?.forceVisibleChallenge = value
            })
            .disposed(by: disposeBag)
    }

    private func setupReCaptcha() {
        // swiftlint:disable:next force_try
        recaptcha = try! ReCaptcha(endpoint: endpoint, locale: locale)

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = Constants.webViewTag

            // For testing purposes
            // If the webview requires presentation, this should work as a way of detecting the webview in UI tests
            self?.view.viewWithTag(Constants.testLabelTag)?.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            label.tag = Constants.testLabelTag
            label.accessibilityLabel = "webview"
            self?.view.addSubview(label)
        }
    }
}
