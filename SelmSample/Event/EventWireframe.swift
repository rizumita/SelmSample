//
// Created by 和泉田 領一 on 2019-04-13.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Selm

protocol EventWireframeProtocol: LifecycleWireframeProtocol where View: EventViewProtocol {
    func showView(dispatch: @escaping Dispatch<EventPage.Msg>) -> View
}

class EventWireframe: EventWireframeProtocol {
    weak var viewController: EventViewController?
    weak var parent:         UIViewController?

    func showView(dispatch: @escaping Dispatch<EventPage.Msg>) -> EventViewController {
        if let controller = viewController {
            controller.dispatch = dispatch
            return controller
        } else {
            guard let controller = UIStoryboard(name: "EventView",
                                                bundle: .none).instantiateInitialViewController() as? EventViewController
                else { fatalError("Unable to instantiate EventViewController") }
            controller.dispatch = dispatch
            viewController = controller
            observeLifecycle(viewController: controller, dispatch: dispatch)
            parent?.navigationController?.pushViewController(controller, animated: true)

            return controller
        }
    }
}
