//
//  Result+Helpers.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 13/04/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import Result


extension Result {
    var value: T? {
        guard case .success(let value) = self else { return nil }
        return value
    }

    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
