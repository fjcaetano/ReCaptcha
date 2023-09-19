//
//  ReCaptcha__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 26/09/17.
//  Copyright © 2018 ReCaptcha. All rights reserved.
//

import AppSwizzle
@testable import ReCaptcha

import XCTest

class ReCaptcha__Tests: XCTestCase {
    fileprivate struct Constants {
        struct InfoDictKeys {
            static let APIKey = "ReCaptchaKey"
            static let Domain = "ReCaptchaDomain"
        }
    }

    func test__Fails_Without_HTML_File() {
        _ = Bundle.swizzleInstanceMethod(
            origSelector: #selector(Bundle.path(forResource:ofType:)),
            toAlterSelector: #selector(Bundle.failHTMLLoad(_:type:))
        )

        do {
            _ = try ReCaptcha()
            XCTFail("Should have failed")
        } catch let e as ReCaptchaError {
            print(e)
            XCTAssertEqual(e, ReCaptchaError.htmlLoadError)
        } catch let e {
            XCTFail("Unexpected error: \(e)")
        }

        // Unswizzle
        _ = Bundle.swizzleInstanceMethod(
            origSelector: #selector(Bundle.path(forResource:ofType:)),
            toAlterSelector: #selector(Bundle.failHTMLLoad(_:type:))
        )
    }

    func test__Base_URL() {
        // Ensures baseURL failure when nil
        do {
            _ = try ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: nil, infoPlistURL: nil)
            XCTFail("Should have failed")
        } catch let e as ReCaptchaError {
            print(e)
            XCTAssertEqual(e, ReCaptchaError.baseURLNotFound)
        } catch let e {
            XCTFail("Unexpected error: \(e)")
        }

        // Ensures plist url if nil key
        let plistURL = URL(string: "https://bar")!
        let config1 = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: nil, infoPlistURL: plistURL)
        XCTAssertEqual(config1?.baseURL, plistURL)

        // Ensures preference of given url over plist entry
        let url = URL(string: "ftp://foo")!
        let config2 = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: url, infoPlistURL: plistURL)
        XCTAssertEqual(config2?.baseURL, url)
    }

    func test__Base_URL_Without_Scheme() {
        // Ignores URL with scheme
        let goodURL = URL(string: "https://foo.bar")!
        let config0 = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: goodURL, infoPlistURL: nil)
        XCTAssertEqual(config0?.baseURL, goodURL)

        // Fixes URL without scheme
        let badURL = URL(string: "foo")!
        let config = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: badURL, infoPlistURL: nil)
        XCTAssertEqual(config?.baseURL.absoluteString, "http://" + badURL.absoluteString)
    }

    func test__API_Key() {
        // Ensures key failure when nil
        do {
            _ = try ReCaptcha.Config(apiKey: nil, infoPlistKey: nil, baseURL: nil, infoPlistURL: nil)
            XCTFail("Should have failed")
        } catch let e as ReCaptchaError {
            print(e)
            XCTAssertEqual(e, ReCaptchaError.apiKeyNotFound)
        } catch let e {
            XCTFail("Unexpected error: \(e)")
        }

        // Ensures plist key if nil key
        let plistKey = "bar"
        let config1 = try? ReCaptcha.Config(
            apiKey: nil,
            infoPlistKey: plistKey,
            baseURL: URL(string: "foo"),
            infoPlistURL: nil
        )
        XCTAssertEqual(config1?.apiKey, plistKey)

        // Ensures preference of given key over plist entry
        let key = "foo"
        let config2 = try? ReCaptcha.Config(
            apiKey: key,
            infoPlistKey: plistKey,
            baseURL: URL(string: "foo"),
            infoPlistURL: nil
        )
        XCTAssertEqual(config2?.apiKey, key)
    }

    func test__Force_Visible_Challenge() {
        let recaptcha = ReCaptcha(manager: ReCaptchaWebViewManager())

        // Initial value
        XCTAssertFalse(recaptcha.forceVisibleChallenge)

        // Set true
        recaptcha.forceVisibleChallenge = true
        XCTAssertTrue(recaptcha.forceVisibleChallenge)
    }
}


private extension Bundle {
    @objc func failHTMLLoad(_ resource: String, type: String) -> String? {
        guard resource == "recaptcha" && type == "html" else {
            return failHTMLLoad(resource, type: type)
        }

        return nil
    }
}
