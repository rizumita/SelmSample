//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit

protocol AppWireframeProtocol {
    associatedtype SignInWireframeType: SignInWireframeProtocol
    associatedtype TimelineWireframeType: TimelineWireframeProtocol

    var signInWireframe:   SignInWireframeType { get }
    var timelineWireframe: TimelineWireframeType { get }
}

class AppWireframe: AppWireframeProtocol {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let signInWireframe:   SignInWireframe
    let timelineWireframe: TimelineWireframe

    init() {
        signInWireframe = SignInWireframe(window: window)
        timelineWireframe = TimelineWireframe(window: window)
    }

    func showSplash() {
        guard let controller = UIStoryboard(name: "LaunchScreen", bundle: .none).instantiateInitialViewController()
            else { fatalError("Unable to instantiate LaunchScreen controller") }
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}
