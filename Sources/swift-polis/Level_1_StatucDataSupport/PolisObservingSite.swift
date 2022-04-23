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


//MARK: - Observing Site -

public struct PolisObservingSite: Codable {
    public var item: PolisItem   // Observing Site Identification

    public var startDate: Date?  // Could be nil if unknown
    public var endDate: Date?    // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)

    public var location: PolisObservingLocation

    public var observatories: [PolisObservatory]
}

