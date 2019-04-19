//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Swiftz
import Selm

struct App {
    struct Model {
        var signInPageModel:   SignInPage.Model?   = .none
        var timelinePageModel: TimelinePage.Model? = .none
    }

    enum Msg {
        case signInPageMsg(SignInPage.Msg)
        case timelinePageMsg(TimelinePage.Msg)
        case goToSignInPage
        case goToTimelinePage(AccessToken)
    }

    static func initialize() -> (Model, Cmd<Msg>) {
        return (Model(), Cmd.ofMsg(.goToSignInPage))
    }

    static let update: SelmUpdate<Msg, Model> = { msg, model in
        switch msg {
        case .signInPageMsg(let sipMsg):
            guard let sipModel = model.signInPageModel else { return (model, .none) }

            let (m, cmd, extMsg) = SignInPage.update(sipMsg, sipModel)
            switch extMsg {
            case .noOp:
                return (model |> set(\Model.signInPageModel, m),
                        cmd.map(Msg.signInPageMsg))

            case .navigateToTimelinePage(let accessToken):
                return (model |> set(\Model.signInPageModel, .none),
                        Cmd.ofMsg(.goToTimelinePage(accessToken)))
            }

        case .timelinePageMsg(let tlpMsg):
            guard let tlpModel = model.timelinePageModel else { return (model, .none) }

            let (m, cmd, extMsg) = TimelinePage.update(tlpMsg, tlpModel)
            switch extMsg {
            case .noOp:
                return (model |> set(\Model.timelinePageModel, m),
                        cmd.map(Msg.timelinePageMsg))

            case .navigateToSignInPage:
                return (model |> set(\Model.timelinePageModel, .none),
                        Cmd.ofMsg(.goToSignInPage))
            }

        case .goToSignInPage:
            let (sipModel, sipCmd) = SignInPage.initialize()
            return (model |> set(\Model.signInPageModel, sipModel),
                    sipCmd.map(Msg.signInPageMsg))

        case .goToTimelinePage(let accessToken):
            let (tlpModel, tlpCmd) = TimelinePage.initialize(accessToken: accessToken)
            return (model |> set(\Model.timelinePageModel, tlpModel),
                    tlpCmd.map(Msg.timelinePageMsg))
        }
    }

    static func route<Wireframe: AppWireframeProtocol>(wireframe: Wireframe) -> SelmView<Msg, Model> {
        return { model, dispatch in
            if let sipModel = model.signInPageModel {
                SignInPage.route(wireframe: wireframe.signInWireframe)(sipModel, dispatch • Msg.signInPageMsg)
            } else if let tlpModel = model.timelinePageModel {
                TimelinePage.route(wireframe: wireframe.timelineWireframe)(tlpModel, dispatch • Msg.timelinePageMsg)
            }
        }
    }
}
