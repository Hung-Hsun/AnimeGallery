//
//  AlertUtility.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import Foundation
import UIKit

protocol AlertShowing {
    func showAlert(title: String?, msg: String, dismissText: String, withActions actions: [UIAlertAction])
}

class AlertUtility: AlertShowing {
    
    static let shared = AlertUtility()
    
    func showAlert(title: String? = nil, msg: String, dismissText: String = "OK", withActions actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction((UIAlertAction(title: dismissText, style: .default, handler: { (_) -> Void in

            alert.dismiss(animated: true, completion: nil)

        })))
        for action in actions {
            alert.addAction(action)
            alert.preferredAction = action
        }
        self.topMostController()?.present(alert, animated: true, completion: nil)
    }
    
    func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
}
