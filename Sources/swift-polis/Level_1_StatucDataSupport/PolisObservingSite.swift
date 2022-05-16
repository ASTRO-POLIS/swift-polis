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

public struct PolisObservingSite: PolisObservatory {
    public private(set) var type = PolisObservatoryType.observingSite
    public var modeOfOperation   = PolisObservatoryModeOfOperation.unknown

    public var item: PolisItem

    public var startDate: Date?
    public var endDate: Date?

    public var location: PolisObservingLocation

    public var instruments: [PolisInstrument]
}
