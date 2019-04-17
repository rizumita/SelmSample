//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Promises
import Swiftz

struct Timeline: Equatable {
    var events: [Event]

    static func ==(lhs: Timeline, rhs: Timeline) -> Bool {
        if lhs.events != rhs.events { return false }
        return true
    }
}

extension Timeline {
    static func fetch(accessToken: AccessToken) -> Promise<Timeline> {
        return Promise(on: .global()) { fulfill, reject in
            [Event(uuid: UUID(), name: "first"),
             Event(uuid: UUID(), name: "second"),
             Event(uuid: UUID(), name: "third")]
            |> Timeline.init(events:)
            |> fulfill
        }
    }
}
