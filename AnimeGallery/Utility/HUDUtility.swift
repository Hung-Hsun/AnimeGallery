//
//  HUDUtility.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import Foundation
import MBProgressHUD
import PKHUD

protocol HUDShowing {
    
}

class HUDUtility: NSObject, HUDShowing, MBProgressHUDDelegate {
    
    static let shared = HUDUtility()
    var progressHUD: MBProgressHUD?
    
    //MBProgressHUD
    func endHud() {
        guard let hud = self.progressHUD else {
            return
        }
        hud.delegate = nil
        hud.removeFromSuperview()
        self.progressHUD = nil
    }

    func hudWasHidden(_ hud: MBProgressHUD) {
        self.endHud()
    }
    
    func displayProgressHud(msg: String) {
        self.endHud()

        if let view = self.topMostController()?.view {
            let hud = MBProgressHUD(view: view)

            hud.delegate = self
            hud.label.text = msg
            hud.minSize = CGSize(width: 100.0, height: 44.0)
            hud.mode = .indeterminate
            hud.backgroundView.style = .solidColor
            hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.1)

            view.addSubview(hud)
            self.progressHUD = hud
            self.progressHUD?.show(animated: true)
        }
    }
    
    //PKHUD
    func showMessageOnly(_ message: String, interval: TimeInterval) {
        HUD.dimsBackground = false
        HUD.flash(.label(message), delay: interval)
    }
    
    //Find top view controller
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
