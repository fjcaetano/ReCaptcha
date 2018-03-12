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
