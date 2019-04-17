//
// Created by 和泉田 領一 on 2019-04-12.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation

struct AccessToken: Equatable {
    let value: String

    static func ==(lhs: AccessToken, rhs: AccessToken) -> Bool {
        if lhs.value != rhs.value { return false }
        return true
    }
}
