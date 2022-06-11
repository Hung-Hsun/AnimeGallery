//
//  Extensions.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/11.
//

import Foundation
import UIKit
import WebKit

extension UIViewController {
    enum NavigationItem {
        case Left
        case Right
    }
    
    func setBlackDismissBackButton(action: Selector?, type: NavigationItem = .Left) {
        var dissmissBtn = UIBarButtonItem()
        switch type {
        case .Left:
            dissmissBtn = UIBarButtonItem(image: UIImage(named: "blackBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: action)
            self.navigationItem.leftBarButtonItem = dissmissBtn
        case .Right:
            dissmissBtn = UIBarButtonItem(image: UIImage(named: "whiteClose")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: action)
            self.navigationItem.rightBarButtonItem = dissmissBtn
        }
        self.navigationItem.leftBarButtonItem = dissmissBtn
    }
    
    func setBlackBackButton() {
        let backBtn = UIBarButtonItem(image: UIImage(named: "blackBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backViewBtnFnc))
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func backViewBtnFnc() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WKWebView {
    func loadRequestFromString(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            self.load(request as URLRequest)
        } else {
            self.loadHTMLString(urlString, baseURL: nil)
        }
    }
}

extension UINavigationController {
    
    enum NavigationBarBackgroundStyle {
        case Opaque
        case Transparent
        case Default
    }
    
    func setNavigationBarAppearance(_ backgroundStyle: NavigationBarBackgroundStyle, titleColor: UIColor = .black) {
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            
            switch backgroundStyle {
            case .Opaque:
                navBarAppearance.configureWithOpaqueBackground()
            case .Transparent:
                navBarAppearance.configureWithTransparentBackground()
            case .Default:
                navBarAppearance.configureWithDefaultBackground()
            }
            
            navBarAppearance.titleTextAttributes = [.foregroundColor: titleColor]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
            navBarAppearance.shadowColor = .clear
            navBarAppearance.shadowImage = UIImage()
            self.navigationBar.scrollEdgeAppearance = navBarAppearance
            self.navigationBar.standardAppearance = navBarAppearance
        }
    }
}

extension UITableView {
    func setEmptyView(iconName: String?, messages: String) {
        let emptyView = EmptyView(frame: self.bounds)

        if let iconName = iconName {
            emptyView.icon.image = UIImage(named: iconName)
        } else {
            emptyView.icon.isHidden = true
        }

        emptyView.messages.text = messages
        self.backgroundView = emptyView
        //self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        //self.separatorStyle = .singleLine
    }
}

extension UICollectionViewCell {
    static var reusableId: String {
        return self.className
    }
}

extension UITableViewCell {
    static var reusableId: String {
        return self.className
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
