//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation

struct Username: Equatable {
    var value: String

    static func ==(lhs: Username, rhs: Username) -> Bool {
        if lhs.value != rhs.value { return false }
        return true
    }

    init(_ value: String) { self.value = value }
}
