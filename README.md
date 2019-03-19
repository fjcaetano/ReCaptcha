# ReCaptcha

[![Build Status](https://travis-ci.org/fjcaetano/ReCaptcha.svg?branch=master)](https://travis-ci.org/fjcaetano/ReCaptcha)
[![Version](https://img.shields.io/cocoapods/v/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![License](https://img.shields.io/cocoapods/l/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![Platform](https://img.shields.io/cocoapods/p/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![codecov](https://codecov.io/gh/fjcaetano/ReCaptcha/branch/master/graph/badge.svg)](https://codecov.io/gh/fjcaetano/ReCaptcha)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

-----

Add Google's [Invisible ReCaptcha](https://developers.google.com/recaptcha/docs/invisible) to your project. This library
automatically handles ReCaptcha's events and retrieves the validation token or notifies you to present the challenge if
invisibility is not possible.

![Example Gif 2](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example2.gif)  ![Example Gif](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example.gif)

#### _Warning_ ⚠️

Beware that this library only works for Invisible ReCaptcha keys! Make sure to check the Invisible reCAPTCHA option
when creating your [API Key](https://www.google.com/recaptcha/admin).

When using http://localhost domain make sure the `Verify the origin of reCAPTCHA solutions` tickbox is unchecked in Recaptcha Admin Console.

![Example Verify Origin](https://raw.githubusercontent.com/rachitmishra/ReCaptcha/patch-1/example-verify-domain.png)
      

## Installation

ReCaptcha is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).
To install it, simply add the following line to your dependencies file:

#### Cocoapods
``` ruby
pod "ReCaptcha"
# or
pod "ReCaptcha/RxSwift"
```

#### Carthage
``` ruby
github "fjcaetano/ReCaptcha"
```

Carthage will create two different frameworks named `ReCaptcha` and `ReCaptcha_RxSwift`, the latter containing the RxSwift
extension for the ReCaptcha framework.

## Usage

Simply add `ReCaptchaKey` and `ReCaptchaDomain` (with a protocol ex. http:// or https://) to your Info.plist and run:

``` swift
let recaptcha = try? ReCaptcha()

override func viewDidLoad() {
    super.viewDidLoad()

    recaptcha?.configureWebView { [weak self] webview in
        webview.frame = self?.view.bounds ?? CGRect.zero
    }
}


func validate() {
    recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
        print(try? result.dematerialize())
    }
}
```

You can also install the reactive subpod and use it with RxSwift:

``` swift
recaptcha.rx.validate(on: view)
    .subscribe(onNext: { (token: String) in
        // Do something
    })
```

#### Alternte endpoint

If your app has firewall limitations that may be blocking Google's API, the JS endpoint may be changed on initialization.
It'll then point to `https://www.recaptcha.net/recaptcha/api.js`:

``` swift
public enum Endpoint {
    case default, alternate
}

let recaptcha = try? ReCaptcha(endpoint: .alternate) // Defaults to `default` when unset
```

## Help Wanted

Do you love ReCaptcha and work actively on apps that use it? We'd love if you could help us keep improving it!
Feel free to message us or to start contributing right away!

## [Full Documentation](http://fjcaetano.github.io/ReCaptcha)

## License

ReCaptcha is available under the MIT license. See the LICENSE file for more info.
