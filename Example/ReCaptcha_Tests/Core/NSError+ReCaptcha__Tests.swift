//
//  NSError+ReCaptcha__Tests.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

@testable import ReCaptcha

import XCTest


class NSError_ReCaptcha__Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func test__Init() {
        // Without userInfo
        let rawErrorCode1 = Int(arc4random_uniform(4))
        let errorCode1 = NSError.ReCaptchaCode(rawValue: rawErrorCode1)
        let err1 = NSError(code: errorCode1!)
        
        XCTAssertEqual(err1.domain, kReCaptchaErrorDomain)
        XCTAssertEqual(err1.code, rawErrorCode1)
        XCTAssertEqual(err1.code, errorCode1!.rawValue)
        
        
        // With userInfo
        let userInfo: [AnyHashable: Any] = ["foo": "bar"]
        let rawErrorCode2 = Int(arc4random_uniform(4))
        let errorCode2 = NSError.ReCaptchaCode(rawValue: rawErrorCode2)
        let err2 = NSError(code: errorCode2!, userInfo: userInfo)
        
        XCTAssertEqual(err2.domain, kReCaptchaErrorDomain)
        XCTAssertEqual(err2.code, rawErrorCode2)
        XCTAssertEqual(err2.code, errorCode2!.rawValue)
        XCTAssertEqual(err2.userInfo["foo"] as? String, "bar")
        XCTAssertNotNil(err2.userInfo[NSLocalizedDescriptionKey])
    }
    
    
    func test__Code() {
        let rawErrorCode = Int(arc4random_uniform(4))
        let errorCode = NSError.ReCaptchaCode(rawValue: rawErrorCode)
        
        XCTAssertNotNil(errorCode)
        XCTAssertEqual(errorCode?.rawValue, rawErrorCode)
    }
    
    func test__RC_Code() {
        // Invalid error
        let err1 = NSError(domain: "foo", code: 0, userInfo: nil)
        XCTAssertNil(err1.rc_code)
        
        
        // Valid error
        let code = NSError.ReCaptchaCode.apiKeyNotFound
        let err2 = NSError(code: code)
        
        XCTAssertEqual(err2.rc_code, code)
    }
}
