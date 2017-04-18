# ReCaptcha

[![Build Status](https://travis-ci.org/fjcaetano/ReCaptcha.svg?branch=master)](https://travis-ci.org/fjcaetano/ReCaptcha)
[![Version](https://img.shields.io/cocoapods/v/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![License](https://img.shields.io/cocoapods/l/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![Platform](https://img.shields.io/cocoapods/p/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![codecov](https://codecov.io/gh/fjcaetano/ReCaptcha/branch/master/graph/badge.svg)](https://codecov.io/gh/fjcaetano/ReCaptcha)

-----

Add Google's [Invisible ReCaptcha](https://developers.google.com/recaptcha/docs/invisible) to your project. This library
automatically handles ReCaptcha's events and retrieves the validation token or notifies you to present the challenge if
invisibility is not possible.

![Example Gif](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example.gif)

## Installation

ReCaptcha is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your
Podfile:

``` ruby
pod "ReCaptcha/RxSwift"
```

## Usage

Simply add `ReCaptchaKey` and `ReCaptchaDomain` to your Info.plist and run:

``` swift
let recaptcha = try? ReCaptcha()

override func viewDidLoad() {
    super.viewDidLoad()

    recaptcha?.configureWebView { [weak self] (webview: WKWebView) in
        // Add constraints and configure it for display
        webview.frame = self?.view.bounds ?? CGRect.zero
    }
}


func validate() {
    recaptcha?.validate(on: view) { [weak self] (result: Result<String, NSError>) in
        print(try? result.dematerialize())
    }
}
```

You can also install the reactive subpod and use it with RxSwift:

``` swift
recaptcha.rx.validate(on: view)
    .map { try $0.dematerialize() }
    .subscribe(onNext: { (token: String) in
        // Do something
    })
```

## License

ReCaptcha is available under the MIT license. See the LICENSE file for more info.
