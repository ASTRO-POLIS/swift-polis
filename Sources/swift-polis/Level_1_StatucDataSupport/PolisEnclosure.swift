//
//  PolisEnclosure.swift
//  
//
//  Created by Georg Tuparev on 21/12/2021.
//

import Foundation

public enum PolisEnclosureType: String, Codable {
    case dome      = "dome"
    case rollOff   = "roll_off"
    case clamshell = "clamshell"
    case other     = "other"
}

public protocol PolisEnclosureContainable: Codable {
    var enclosureType: PolisEnclosureType { get set }
}

//TODO: Make codable!
public class PolisEnclosure {
    public private(set) var attributes: PolisItemAttributes
    public let type: PolisEnclosureType
    public let content: [PolisEnclosureContainable]

    public init(attributes: PolisItemAttributes, type: PolisEnclosureType = .other, content: [PolisEnclosureContainable] = [PolisEnclosureContainable]()) {
        self.attributes = attributes
        self.type       = type
        self.content    = content
    }
}
