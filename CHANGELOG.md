# 1.6.0

- RxSwift 6.0.0 support (#101)
- Feature: added 2 new cases to ReCaptchaError (`.responseExpired` and `.failedRender`) (#79)

- Fix: retire JS arrow functions in favor of standard functions (#78)

# 1.5.0

- Swift 5.0 support
- Feature: `didFinishLoading` callback notifier
  
- Fix: Resources loading validation (#72 #56 #60)

# 1.4.2

- Fix: Webview's resource loading detection (#56 #60)

# 1.4.1

- Fix RxSwift dependency version (#58)

# 1.4

- Feature: Support Swift 4.2
- Feature: enable validation to be skipped for testing

# 1.3.1

- Fix: Removing leftover print
- Fix: Removing Result dependency from Carthage

# 1.3

- Feature: Locale support (#39)

- Fix: Reset not flagging ReCaptha as ready-to-execute (#36)
- Fix: Multiple configure calls after app being idle (#40)

# 1.2

- Feature: Resettable ReCaptchas. (#23)
- Feature: Forcing visible challenge on DEBUG. (#19)

- Fix: Better encapsulation architecture.
- Fix: Retiring Result dependency. (#24)
- Fix: `validate` completion closure being called consecutively. (#29)
- Fix: `configureWebView` being called multiple times. (#31)

# 1.1

- Fix: better logging for when protocol isn't found on
- Fix: Alternate endpoint not loading
- Fix: Prepends a scheme if `baseURL` doesn't have one

# 1.0.2

- Fix: Better detection of resources loading end (#16)

# 1.0.1

- Fix: Webview content being dismissed when clicking outside of div frame area (#14)

# 1.0.0

- Swift 4 support

# 0.3.0

- Carthage support
- Refactored framework errors
- Alternate endpoint to bypass firewall limitations (#10)
- Fix: JS not loaded (#7)
- Fix: Wrong Domain retrieving (#6)

# 0.2.0

- Removing `presenterView` from ReCaptchaWebViewManager
- Adding view to `validate(on:)` parameters
