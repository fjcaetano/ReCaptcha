# ReCaptcha

[![Version](https://img.shields.io/cocoapods/v/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![License](https://img.shields.io/cocoapods/l/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![Platform](https://img.shields.io/cocoapods/p/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)

-----

Add Google's [Invisible ReCaptcha](https://developers.google.com/recaptcha/docs/invisible) to your project. This library
automatically handles ReCaptcha's events and retrieves the validation token or notifies you to present the challenge if 
invisibility is not possible.

## Installation

ReCaptcha is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your
Podfile:

``` ruby
pod "ReCaptcha"
```

## Usage

Simply add `ReCaptchaKey` and `ReCaptchaDomain` to your Info.plist and run:

``` swift
let recaptcha = try? ReCaptcha()

override func viewDidLoad() {
    super.viewDidLoad()

    recaptcha?.presenterView = view
    recaptcha?.configureWebView { [weak self] webview in
        webview.frame = self?.view.bounds ?? CGRect.zero
        webview.tag = ViewController.webViewTag
    }
}


func validate() {
    recaptcha?.validate { [weak self] result in
        print(try? result.dematerialize())
    }
}
```

## Author

Flávio Caetano, flavio@vieiracaetano.com

## License

ReCaptcha is available under the MIT license. See the LICENSE file for more info.
