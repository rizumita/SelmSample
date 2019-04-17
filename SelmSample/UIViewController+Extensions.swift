//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit

extension UIViewController {
    var hasBacked: Bool { return isMovingFromParent || isBeingDismissed }
}
