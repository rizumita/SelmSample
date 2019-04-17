//
//  TokenInputViewController.swift
//  SelmSample
//
//  Created by 和泉田 領一 on 2019-04-08.
//  Copyright © 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Swiftz
import Selm

protocol SignInViewProtocol: ViewProtocol {
    var dispatch: Dispatch<SignInPage.Msg>! { get set }

    func setEnabledToSignInButton(_ enabled: Bool)
    func setShowsIndicator(_ shows: Bool)
    func showErrorMessage(_ message: String)
}

class SignInViewController: UIViewController {
    var dispatch: Dispatch<SignInPage.Msg>!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton:      UIButton!
    @IBOutlet weak var indicator:         UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTextDidChange(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: .none)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleTextDidChange(_ notification: Notification) {
        switch notification.object {
        case let textField as UITextField where textField === usernameTextField:
            dispatch(.inputUsername(textField.text ?? ""))
        case let textField as UITextField where textField === passwordTextField:
            dispatch(.inputPassword(textField.text ?? ""))
        default: ()
        }
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        dispatch(.signIn)
    }
}

extension SignInViewController: SignInViewProtocol {
    func setEnabledToSignInButton(_ enabled: Bool) {
        signInButton.isEnabled = enabled
    }

    func setShowsIndicator(_ shows: Bool) {
        if shows {
            indicator.isHidden = false
            indicator.startAnimating()
        } else {
            indicator.isHidden = true
            indicator.stopAnimating()
        }
    }

    func showErrorMessage(_ message: String) {
        UIAlertController(title: .none, message: message, preferredStyle: .alert)
        |> tee { $0.addAction(UIAlertAction(title: "Dismiss", style: .cancel)) }
        |> { present($0, animated: true) }
    }
}
