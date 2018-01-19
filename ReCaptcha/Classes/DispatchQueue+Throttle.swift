//
//  DispatchQueue+Throttle.swift
//  ReCaptcha
//
//  Created by Flávio Caetano on 21/12/17.
//  Copyright © 2017 ReCaptcha. All rights reserved.
//

import Foundation

/// Adds throttling to dispatch queues
extension DispatchQueue {
    /// Stores a throttle DispatchWorkItem instance for a given context
    private static var workItems = [AnyHashable: DispatchWorkItem]()

    /// An object representing a context if none is given
    private static let nilContext = UUID()

    /**
     - parameters:
         - deadline: The timespan to delay a closure execution
         - context: The context in which the throttle should be executed
         - action: The closure to be executed
     
     Delays a closure execution and ensures no other executions are made during deadline for that context
     */
    func throttle(deadline: DispatchTime, context: AnyHashable = nilContext, action: @escaping () -> Void) {
        let worker = DispatchWorkItem {
            defer { DispatchQueue.workItems.removeValue(forKey: context) }
            action()
        }

        asyncAfter(deadline: deadline, execute: worker)

        DispatchQueue.workItems[context]?.cancel()
        DispatchQueue.workItems[context] = worker
    }
}
