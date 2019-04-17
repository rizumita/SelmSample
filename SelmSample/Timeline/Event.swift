//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation

struct Event: Equatable {
    var uuid: UUID
    var name: String

    static func ==(lhs: Event, rhs: Event) -> Bool {
        if lhs.uuid != rhs.uuid { return false }
        if lhs.name != rhs.name { return false }
        return true
    }

}
