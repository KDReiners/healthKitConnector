//
//  extensions.swift
//  healthKitConnector
//
//  Created by Klaus-Dieter Reiners on 20.11.21.
//

import Foundation
extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

