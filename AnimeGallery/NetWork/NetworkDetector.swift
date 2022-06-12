//
//  NetworkDetector.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/12.
//

import UIKit
import Network

class NetworkDetector: NSObject {

    static let alertUtility = AlertUtility.shared
    static let monitor = NWPathMonitor()
    
    static func startNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                alertUtility.showAlert(msg: "No Network Connection!")
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}
