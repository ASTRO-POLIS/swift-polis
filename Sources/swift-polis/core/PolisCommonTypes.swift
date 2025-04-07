//
//  PolisCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 19.02.25.
//

import Foundation

public enum PolisSorting {
    case none
    case dateAndTime
    case lastUpdated
}

protocol StorableItem {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject
    func parentItem() -> (any StorableItem)?
    mutating func flashUsing(manager: PolisProviderManager) throws
}


