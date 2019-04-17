//
// Created by 和泉田 領一 on 2019-04-13.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import UIKit
import Promises

extension UIAlertController {
    struct Cancel: Error {
    }

    static func prompt(presenter: UIViewController) -> () -> Promise<String?> {
        return {
            Promise { fulfill, reject in
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                alert.addTextField()
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    fulfill(alert.textFields?.first?.text)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in reject(Cancel()) })
                presenter.present(alert, animated: true)
            }
        }
    }
}
