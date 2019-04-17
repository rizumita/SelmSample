//
// Created by 和泉田 領一 on 2019-04-17.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation

enum SigningState: Equatable {
    case unsignedIn
    case signingIn
    case signedIn

    static func isSigning(_ state: SigningState) -> Bool {
        return state == .signingIn
    }
}
