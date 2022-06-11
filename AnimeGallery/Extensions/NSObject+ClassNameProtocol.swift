//
//  NSObject+ClassNameProtocol.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/11.
//

import Foundation

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}
