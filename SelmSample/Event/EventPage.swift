//
// Created by 和泉田 領一 on 2019-04-13.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Swiftz
import Promises
import Selm

struct EventPage {
    struct Model: Equatable {
        var event:        Event
        var isViewLoaded: Bool

        static func ==(lhs: Model, rhs: Model) -> Bool {
            if lhs.event != rhs.event { return false }
            if lhs.isViewLoaded != rhs.isViewLoaded { return false }
            return true
        }
    }

    enum Msg: LifecycleMsgProtocol {
        case viewDidLoad
        case inputEventName(() -> Promise<String?>)
        case updateEventName(String)
        case dismiss

        static var loadedMsg:     Msg? { return .viewDidLoad }
        static var dismissingMsg: Msg? { return .dismiss }
    }

    enum ExternalMsg {
        case noOp
        case eventUpdated(Event)
        case dismiss
    }

    static func initialize(event: Event) -> SelmInited<Msg, Model> {
        clearDependsOn(Model.self)
        return (Model(event: event, isViewLoaded: false), Cmd.none)
    }

    static let update: SelmUpdateExt<Msg, ExternalMsg, Model> = { msg, model in
        switch msg {
        case .viewDidLoad:
            return (model |> set(\Model.isViewLoaded, true),
                    Cmd.none,
                    .noOp)

        case .inputEventName(let input):
            return (model, inputEventNameCmd(input()), .noOp)

        case .updateEventName(let name):
            let eventNameKeyPath = (\Model.event).appending(path: \Event.name)
            let newModel         = model |> set(eventNameKeyPath, name)
            return (newModel, Cmd.none, .eventUpdated(newModel.event))

        case .dismiss:
            return (model, Cmd.none, .dismiss)
        }
    }

    static func view<Wireframe: EventWireframeProtocol>(wireframe: Wireframe) -> SelmView<Msg, Model> {
        return { model, dispatch in
            let view = wireframe.showView(dispatch: dispatch)
            guard model.isViewLoaded, !view.isAboutToClose else { return }

            dependsOn((\Model.event).appending(path: \Event.name), model, view.setEventName)
        }
    }
}

private extension EventPage {
    static func inputEventNameCmd(_ input: Promise<String?>) -> Cmd<Msg> {
        return Cmd.ofAsyncCmd { fulfill in
            input.validate { s in s?.isEmpty == false }
                 .then { value -> Cmd<Msg> in
                     guard let value = value else { return Cmd<Msg>.none }
                     return Cmd<Msg>.ofMsg(.updateEventName(value))
                 }
                 .recover { _ -> Cmd<Msg> in Cmd.none }
                 .then(fulfill)
        }
    }
}
