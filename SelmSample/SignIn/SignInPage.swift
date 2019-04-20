//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation
import Swiftz
import Promises
import Selm

struct SignInPage {
    struct Model: Equatable {
        var signingState: SigningState = .unsignedIn
        var username:     Username     = Username("")
        var password:     Password     = Password("")
        var errorMessage: String?

        static func ==(lhs: Model, rhs: Model) -> Bool {
            if lhs.signingState != rhs.signingState { return false }
            if lhs.username != rhs.username { return false }
            if lhs.password != rhs.password { return false }
            if lhs.errorMessage != rhs.errorMessage { return false }
            return true
        }
    }

    enum Msg {
        case inputUsername(String)
        case updateUsername(Username)
        case inputPassword(String)
        case updatePassword(Password)
        case signIn
        case goToTimelinePage(AccessToken)
        case showError(String)
        case eraseError
    }

    enum ExternalMsg {
        case noOp
        case navigateToTimelinePage(AccessToken)
    }

    static func initialize() -> (Model, Cmd<Msg>) {
        return (Model(), Cmd.none)
    }

    static let update: SelmUpdateExt<Msg, ExternalMsg, Model> = { msg, model in
        switch msg {
        case .inputUsername(let tokenString):
            return (model, inputUsernameCmd(tokenString), .noOp)

        case .updateUsername(let username):
            return (model |> set(\.username, username), Cmd.none, .noOp)

        case .inputPassword(let secretString):
            return (model, inputPasswordCmd(secretString), .noOp)

        case .updatePassword(let password):
            return (model |> set(\.password, password), Cmd.none, .noOp)

        case .signIn:
            return (model |> set(\Model.signingState, .signingIn),
                    signInCmd(username: model.username, password: model.password),
                    .noOp)

        case .goToTimelinePage(let accessToken):
            return (model |> set(\Model.signingState, .signedIn), Cmd.none, .navigateToTimelinePage(accessToken))

        case .showError(let message):
            return (model |> set(\Model.errorMessage, message) |> set(\Model.signingState, .unsignedIn),
                    Cmd.ofMsg(.eraseError),
                    .noOp)

        case .eraseError:
            return (model |> set(\Model.errorMessage, .none), Cmd.none, .noOp)
        }
    }

    static func view<Wireframe: SignInWireframeProtocol>(wireframe: Wireframe) -> SelmView<Msg, Model> {
        return { model, dispatch in
            let view = wireframe.showView(dispatch: dispatch)
            dependsOn(\Model.signingState, model, view.setShowsIndicator • SigningState.isSigning)
            dependsOn(\Model.signingState, \Model.username, \Model.password, model, view.setEnabledToSignInButton • canSignIn)
            dependsOn(\Model.errorMessage, model, view.showErrorMessage |> unwrap)
        }
    }
}

private extension SignInPage {
    static let debounceUsername: Debounce<String> = debounce(delay: .milliseconds(350))
    static let debouncePassword: Debounce<String> = debounce(delay: .milliseconds(350))

    static func inputUsernameCmd(_ string: String) -> Cmd<Msg> {
        return Cmd.ofAsyncMsgOptional { (fulfill: @escaping (Msg?) -> ()) in
            debounceUsername(string).then(Username.init)
                                    .then(Msg.updateUsername)
                                    .recover { _ in Msg?.none }
                                    .then(fulfill)
        }
    }

    static func inputPasswordCmd(_ string: String) -> Cmd<Msg> {
        return Cmd.ofAsyncMsgOptional { (fulfill: @escaping (Msg?) -> ()) in
            debouncePassword(string).then(Password.init)
                                    .then(Msg.updatePassword)
                                    .recover { _ in Msg?.none }
                                    .then(fulfill)
        }
    }

    static func signInCmd(username: Username, password: Password) -> Cmd<Msg> {
        return Cmd.ofAsyncMsgOptional { fulfill in
            signIn(username: username, password: password)
                .then(Msg.goToTimelinePage)
                .recover { _ -> Msg in Msg.showError("Username and password are wrong.") }
                .then(fulfill)
        }
    }
}

enum SignInError: Error {
    case wrongValue
}

private func canSignIn(state: SigningState, username: Username, password: Password) -> Bool {
    return state == .unsignedIn
           && !username.value.isEmpty
           && !password.value.isEmpty
}

private func signIn(username: Username, password: Password) -> Promise<AccessToken> {
    return Promise { fulfill, reject in
        guard username.value == "abcd",
              password.value == "efgh"
            else { return reject(SignInError.wrongValue) }
        fulfill(AccessToken(value: "token"))
    }.delay(2.0)
}
