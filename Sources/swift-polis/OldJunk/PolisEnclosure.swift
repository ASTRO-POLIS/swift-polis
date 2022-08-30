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
    case dome
    case rollOff
    case clamshell
    case none
    case other
}

//public class PolisEnclosure: Codable {
////    public var item: PolisItem   // Observing Site Identity
//    public var type: PolisEnclosureType
//    public var modeOfOperation: PolisModeOfOperation
//    public var instrumentIDs: [UUID]
//
//    public init(item: PolisItem, type: PolisEnclosureType, modeOfOperation: PolisModeOfOperation = PolisModeOfOperation.unknown, instrumentIDs: [UUID] = [UUID]() ) {
//        self.item            = item
//        self.type            = type
//        self.modeOfOperation = modeOfOperation
//        self.instrumentIDs   = instrumentIDs
//    }
//}


//MARK: - Type extensions -


//public extension PolisEnclosureType {
//    enum CodingKeys: String, CodingKey {
//        case dome      = "dome"
//        case rollOff   = "roll_off"
//        case clamshell = "clamshell"
//        case none      = "none"
//        case other     = "other"
//    }
//}

//public extension PolisEnclosure {
//    enum CodingKeys: String, CodingKey {
//        case item
//        case type
//        case modeOfOperation = "mode_of_operation"
//        case instrumentIDs   = "instrument_ids"
//    }
//}
