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
import SoftwareEtudesUtilities


//MARK: - Ownership -

/// `PolisOwnershipType` defines various ownership types
///
/// `PolisOwnershipType` is used to identify the ownership type of POLIS items (or instruments) - observing sites,
/// telescopes, CCD cameras, weather stations, etc. Different cases should be self-explanatory. `private` should be
/// used by amateurs and hobbyists.
public enum PolisOwnershipType: String, Codable {
    case university
    case research
    case commercial
    case school
    case network
    case government
    case ngo
    case club
    case consortium
    case cooperative
    case `private`
    case other
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.




