//
//  DispatchQueue+Throttle.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 21/12/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import Foundation

private var workItem: DispatchWorkItem?

extension DispatchQueue {
    /**
     - parameters:
         - deadline: The timespan to delay a closure execution
         - action: The closure to be executed
     
     Delays a closure execution and ensures no other executions are made during deadline
     */
    func throttle(deadline: DispatchTime, action: @escaping () -> Void) {
        let worker = DispatchWorkItem {
            defer { workItem = nil }
            action()
        }

        asyncAfter(deadline: deadline, execute: worker)

        workItem?.cancel()
        workItem = worker
    }
}
