//
//  ReCaptcha__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 26/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

@testable import ReCaptcha

import XCTest
import AppSwizzle
import RxSwift


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
        } catch let e as NSError {
            XCTAssertEqual(e.rc_code, .htmlLoadError)
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
        } catch let e as NSError {
            XCTAssertEqual(e.rc_code, .baseURLNotFound)
        }

        // Ensures plist url if nil key
        let plistURL = URL(string: "bar")!
        let config1 = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: nil, infoPlistURL: plistURL)
        XCTAssertEqual(config1?.baseURL, plistURL)

        // Ensures preference of given url over plist entry
        let url = URL(string: "foo")!
        let config2 = try? ReCaptcha.Config(apiKey: "", infoPlistKey: nil, baseURL: url, infoPlistURL: plistURL)
        XCTAssertEqual(config2?.baseURL, url)
    }

    func test__API_Key() {
        // Ensures key failure when nil
        do {
            _ = try ReCaptcha.Config(apiKey: nil, infoPlistKey: nil, baseURL: nil, infoPlistURL: nil)
            XCTFail("Should have failed")
        } catch let e as NSError {
            XCTAssertEqual(e.rc_code, .apiKeyNotFound)
        }

        // Ensures plist key if nil key
        let plistKey = "bar"
        let config1 = try? ReCaptcha.Config(apiKey: nil, infoPlistKey: plistKey, baseURL: URL(string: "foo"), infoPlistURL: nil)
        XCTAssertEqual(config1?.apiKey, plistKey)

        // Ensures preference of given key over plist entry
        let key = "foo"
        let config2 = try? ReCaptcha.Config(apiKey: key, infoPlistKey: plistKey, baseURL: URL(string: "foo"), infoPlistURL: nil)
        XCTAssertEqual(config2?.apiKey, key)
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
