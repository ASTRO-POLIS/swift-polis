//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//


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
