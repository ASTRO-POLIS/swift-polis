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
import CoreText

public enum PolisObservatoryType: String, Codable {
    case site
    case network
}

public protocol PolisObservatory: Codable {
    var modeOfOperation: PolisModeOfOperation { get set }
    var item: PolisItem                       { get set }
    var startDate: Date?                      { get set } // Could be nil if unknown
    var endDate: Date?                        { get set } // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    var location: PolisObservingLocation?     { get set }
    var admin: PolisAdminContact?             { get set }
    var instrumentIDs: [UUID]?                { get set }
    var enclosureIDs: [UUID]?                 { get set }
    var type: PolisObservatoryType            { get }
}
