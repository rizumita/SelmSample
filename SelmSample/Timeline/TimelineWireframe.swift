//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Selm

protocol TimelineWireframeProtocol {
    associatedtype View: TimelineViewProtocol
    associatedtype EventWireframeType: EventWireframeProtocol

    var eventWireframe: EventWireframeType { get }

    func showView(dispatch: @escaping Dispatch<TimelinePage.Msg>) -> View
}

class TimelineWireframe: TimelineWireframeProtocol {
    private var window: UIWindow

    private weak var viewController: TimelineViewController?
    let eventWireframe = EventWireframe()

    init(window: UIWindow) {
        self.window = window
    }

    func showView(dispatch: @escaping Dispatch<TimelinePage.Msg>) -> TimelineViewController {
        if let controller = viewController {
            controller.dispatch = dispatch
            return controller
        } else {
            let controller = TimelineViewController(style: .plain)
            controller.dispatch = dispatch
            viewController = controller
            eventWireframe.parent = controller
            window.rootViewController = UINavigationController(rootViewController: controller)

            return controller
        }
    }
}
