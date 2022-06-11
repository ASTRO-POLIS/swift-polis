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

public class PolisNetwork: PolisObservatory {
    // PolisObservatory
    public var type             = PolisObservatoryType.network
    public var modeOfOperation  = PolisObservatoryModeOfOperation.mixed
    public var item: PolisItem
    public var startDate: Date?
    public var endDate: Date?
    public var location: PolisObservingLocation?
    public var admin: PolisAdminContact?
    public var instrumentIDs: [UUID]?
    public var enclosureIDs: [UUID]?

    // Miscellaneous
    public var sites: [PolisObservingSite]
}


//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisNetwork {
    enum CodingKeys: String, CodingKey {
        case type
        case modeOfOperation = "mode_of_operation"
        case item
        case startDate       = "start_date"
        case endDate         = "end_date"
        case location
        case instrumentIDs   = "instrument_ids"
        case sites
    }
}
