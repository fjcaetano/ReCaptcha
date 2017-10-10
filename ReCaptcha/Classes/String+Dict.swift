//
//  String+Dict.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 10/10/17.
//
//

import Foundation


extension String {
    init(format: String, arguments: [String: CustomStringConvertible]) {
        self.init(describing: arguments.reduce(format)
        { (format: String, args: (key: String, value: CustomStringConvertible)) -> String in
            format.replacingOccurrences(of: "${\(args.key)}", with: args.value.description)
        })
    }
}
