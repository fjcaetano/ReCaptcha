# ReCaptcha

[![Build Status](https://travis-ci.org/fjcaetano/ReCaptcha.svg?branch=master)](https://travis-ci.org/fjcaetano/ReCaptcha)
[![codecov](https://codecov.io/gh/fjcaetano/ReCaptcha/branch/master/graph/badge.svg)](https://codecov.io/gh/fjcaetano/ReCaptcha)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/fjcaetano/ReCaptcha/pulls)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-orange.svg)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![License](https://img.shields.io/cocoapods/l/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)
[![Platform](https://img.shields.io/cocoapods/p/ReCaptcha.svg?style=flat)](http://cocoapods.org/pods/ReCaptcha)

-----

Add Google's [Invisible ReCaptcha v2](https://developers.google.com/recaptcha/docs/invisible) to your project. This library
automatically handles ReCaptcha's events and retrieves the validation token or notifies you to present the challenge if
invisibility is not possible.

![Example Gif 2](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example2.gif)  ![Example Gif](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example.gif)

#### _Warning_ ⚠️

Beware that this library only works for ReCaptcha v2 Invisible keys! Make sure to check the reCAPTCHA
v2 Invisible badge option when creating your [API Key](https://www.google.com/recaptcha/admin/create).

![ReCaptcha v2 invisible key example](https://raw.githubusercontent.com/fjcaetano/ReCaptcha/master/example-v2-key.png)

You won't be able to use a ReCaptcha v3 key because it requires server-side validation. On v3, all
challenges succeed into a token which is then validated in the server for a score. For this reason,
a frontend app can't know on its own wether or not a user is valid since the challenge will always
result in a valid token.

## Installation

ReCaptcha is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).
To install it, simply add the following line to your dependencies file:

#### Cocoapods
``` ruby
pod "ReCaptcha"
# or
pod "ReCaptcha/RxSwift"
```

#### Swift Package Manager

```swift
https://github.com/fjcaetano/ReCaptcha
```

Adding this in project dependency in Xcode will show option to add `ReCaptcha` and `ReCaptchaRx`, the latter containing 
internal dependency for ReCaptcha framework.

#### Carthage

``` ruby
github "fjcaetano/ReCaptcha"
```

Carthage will create two different frameworks named `ReCaptcha` and `ReCaptcha_RxSwift`, the latter containing the RxSwift
extension for the ReCaptcha framework.

## Usage

The reCAPTCHA keys can be specified as Info.plist keys or can be passed as parameters when instantiating ReCaptcha().

For the Info.plist configuration, add `ReCaptchaKey` and `ReCaptchaDomain` (with a protocol ex. http:// or https://) to your Info.plist and run:

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

If instead you prefer to keep the information out of the Info.plist, you can use:
``` swift
let recaptcha = try? ReCaptcha(
    apiKey: "YOUR_RECAPTCHA_KEY", 
    baseURL: URL(string: "YOUR_RECAPTCHA_DOMAIN")!
)

...
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
