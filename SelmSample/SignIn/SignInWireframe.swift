//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Swiftz
import Selm

protocol SignInWireframeProtocol {
    associatedtype View: SignInViewProtocol

    func showView(dispatch: @escaping Dispatch<SignInPage.Msg>) -> View
}

class SignInWireframe: SignInWireframeProtocol {
    private weak var window:         UIWindow?
    private weak var viewController: SignInViewController?

    init(window: UIWindow) {
        self.window = window
    }

    func showView(dispatch: @escaping Dispatch<SignInPage.Msg>) -> SignInViewController {
        if let controller = viewController {
            controller.dispatch = dispatch
            return controller
        } else {
            let controller = UIStoryboard(name: "SignInView",
                                          bundle: .none).instantiateInitialViewController() as! SignInViewController
            controller.dispatch = dispatch
            viewController = controller
            window?.rootViewController = controller
            return controller
        }
    }
}
