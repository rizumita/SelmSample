//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Promises

public struct DebounceCanceled: Error {
}

public typealias Debounce<T> = (T) -> Promise<T>

public func debounce<T>(delay: DispatchTimeInterval,
                        queue: DispatchQueue = DispatchQueue(label: UUID().uuidString)) -> Debounce<T> {
    var lastFireTime = DispatchTime.now()

    return { value in
        return Promise<T>(on: queue) { fulfill, reject in
            let now      = DispatchTime.now()
            let deadline = now + delay
            lastFireTime = now

            queue.asyncAfter(deadline: deadline) {
                let now  = deadline
                let when = lastFireTime + delay

                if now >= when {
                    fulfill(value)
                } else {
                    reject(DebounceCanceled())
                }
            }
        }
    }
}
