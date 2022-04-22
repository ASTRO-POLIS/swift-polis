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

public class PolisWeatherStation: PolisInstrument {
    public var sensors = [PolisSensor]()
}

public extension PolisWeatherStation {
    enum CodingKeys: String, CodingKey {
        case item
        case parent
        case subInstruments = "sub_instruments"
        case sensors
    }
}