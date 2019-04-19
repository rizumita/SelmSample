//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Promises
import Swiftz
import Selm

struct TimelinePage {
    struct Model: Equatable {
        var accessToken:    AccessToken
        var timeline           = Timeline(events: [])
        var eventPageModel: EventPage.Model?
        var reloadsTimeline    = false

        init(accessToken: AccessToken) { self.accessToken = accessToken }

        static func ==(lhs: Model, rhs: Model) -> Bool {
            if lhs.accessToken != rhs.accessToken { return false }
            if lhs.timeline != rhs.timeline { return false }
            if lhs.eventPageModel != rhs.eventPageModel { return false }
            if lhs.reloadsTimeline != rhs.reloadsTimeline { return false }
            return true
        }
    }

    enum Msg {
        case eventPageMsg(EventPage.Msg)
        case fetch
        case selectEvent(IndexPath)
        case updateTimeline(Timeline)
        case updateEvent(Event)
        case goToEventPage(Event)
        case signOut
    }

    enum ExternalMsg {
        case noOp
        case navigateToSignInPage
    }

    static func initialize(accessToken: AccessToken) -> SelmInited<Msg, Model> {
        let model = Model(accessToken: accessToken)
        return (model, Cmd.none)
    }

    static let update: SelmUpdateExt<Msg, ExternalMsg, Model> = { msg, model in
        var model = model |> set(\Model.reloadsTimeline, false)

        switch msg {
        case .eventPageMsg(let epMsg):
            guard let epModel = model.eventPageModel else { fatalError() }

            let (m, cmd, extMsg) = EventPage.update(epMsg, epModel)
            switch extMsg {
            case .noOp:
                return (model |> set(\Model.eventPageModel, m),
                        cmd.map(Msg.eventPageMsg),
                        .noOp)

            case .eventUpdated(let event):
                return (model |> set(\Model.eventPageModel, m),
                        Cmd<Msg>.batch([Cmd.ofMsg(.updateEvent(event)),
                                        cmd.map(Msg.eventPageMsg)]),
                        .noOp)

            case .dismissed:
                return (model |> set(\Model.eventPageModel, .none),
                        Cmd.none,
                        .noOp)
            }

        case .fetch:
            return (model, fetchCmd(accessToken: model.accessToken), .noOp)

        case .selectEvent(let indexPath):
            return (model,
                    Cmd.ofMsg(.goToEventPage(model.timeline.events[indexPath.row])),
                    .noOp)

        case .updateTimeline(let timeline):
            return (model |> set(\.timeline, timeline) |> set(\Model.reloadsTimeline, true),
                    Cmd.none,
                    .noOp)

        case .updateEvent(let event):
            return (model, replaceEventCmd(event, model.timeline), .noOp)

        case .goToEventPage(let event):
            let (m, cmd) = EventPage.initialize(event: event)
            return (model |> set(\Model.eventPageModel, m),
                    cmd.map(Msg.eventPageMsg),
                    .noOp)

        case .signOut:
            return (model, Cmd.none, .navigateToSignInPage)
        }
    }

    static func route<Wireframe: TimelineWireframeProtocol>(wireframe: Wireframe) -> SelmView<Msg, Model> {
        return { model, dispatch in
            let view = wireframe.showView(dispatch: dispatch)
            self.view(view)(model, dispatch)

            if let m = model.eventPageModel {
                EventPage.route(wireframe: wireframe.eventWireframe)(m, dispatch • Msg.eventPageMsg)
            }
        }
    }

    static func view<View: TimelineViewProtocol>(_ view: View) -> SelmView<Msg, Model> {
        return { model, dispatch in
            guard view.isViewLoaded && !view.hasBacked else { return }

            dependsOn(\Model.reloadsTimeline, model) { reloads in
                view.messages = model.timeline.events
                view.reload()
            }
        }
    }
}

private extension TimelinePage {
    static func fetchCmd(accessToken: AccessToken) -> Cmd<Msg> {
        return Cmd.ofAsyncMsgOptional { fulfill in
            Timeline.fetch(accessToken: accessToken)
                    .then(Msg.updateTimeline)
                    .recover { _ -> Msg? in .none }
                    .then(fulfill)
        }
    }

    static func replaceEventCmd(_ event: Event, _ timeline: Timeline) -> Cmd<Msg> {
        guard let index = timeline.events.firstIndex(where: { e in e.uuid == event.uuid }) else { return .none }
        var tl = timeline
        tl.events[index] = event
        return Cmd<Msg>.ofMsg(.updateTimeline(tl))
    }
}
