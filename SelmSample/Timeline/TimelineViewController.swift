//
//  TimelineViewController.swift
//  SelmSample
//
//  Created by 和泉田 領一 on 2019-04-08.
//  Copyright © 2019 CAPH TECH. All rights reserved.@objc
//

import UIKit
import Selm

protocol TimelineViewProtocol: LifecycleViewProtocol {
    var dispatch: Dispatch<TimelinePage.Msg>! { get set }

    var messages: [Event] { get set }

    func reload()
}

class TimelineViewController: UITableViewController {
    var dispatch: Dispatch<TimelinePage.Msg>!
    var messages: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(signOutButtonTapped(_:)))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        dispatch(.fetch)
    }

    deinit {
        print("deinit timeline view controller")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc func signOutButtonTapped(_ sender: Any) {
        dispatch(.signOut)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatch(.selectEvent(indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimelineViewController: TimelineViewProtocol {
    func reload() {
        tableView.reloadData()
        print("reloading...")
    }
}
