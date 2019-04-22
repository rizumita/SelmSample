//
//  EventViewController.swift
//  SelmSample
//
//  Created by 和泉田 領一 on 2019-04-13.
//  Copyright © 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Selm

protocol EventViewProtocol: LifecycleViewProtocol {
    func setEventName(_ name: String)
}

class EventViewController: UIViewController {
    var dispatch: Dispatch<EventPage.Msg>?

    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        print("Event view controller deinit.")
    }

    @IBAction func changeNameButtonTapped(_ sender: Any) {
        dispatch?(.inputEventName(UIAlertController.prompt(presenter: self)))
    }
}

extension EventViewController: EventViewProtocol {
    func setEventName(_ name: String) {
        print("set event name: \(name)")
        nameLabel.text = name
    }
}
