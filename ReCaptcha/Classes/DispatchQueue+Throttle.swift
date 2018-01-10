//
//  DispatchQueue+Throttle.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 21/12/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import Foundation

private var workItems = [AnyHashable: DispatchWorkItem]()
private let nilContext = UUID()

extension DispatchQueue {
    /**
     - parameters:
         - deadline: The timespan to delay a closure execution
         - context: The context in which the throttle should be executed
         - action: The closure to be executed
     
     Delays a closure execution and ensures no other executions are made during deadline for that context
     */
    func throttle(deadline: DispatchTime, context: AnyHashable = nilContext, action: @escaping () -> Void) {
        let worker = DispatchWorkItem {
            defer { workItems[context] = nil }
            action()
        }

        asyncAfter(deadline: deadline, execute: worker)

        workItems[context]?.cancel()
        workItems[context] = worker
    }
}
