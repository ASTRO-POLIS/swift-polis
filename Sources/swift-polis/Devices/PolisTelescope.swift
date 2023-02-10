//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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


/// `PolisTelescope` is an instrument to observe astronomical objects composed by a hierarchy of devices with the possiblity of being arranged in different configurations.
///
/// It contains a type defining how the sub devices are set up (e.g. reflector, refractor etc.), the part of the electromagnetic spectrum it covers, along with other properties such as network membership, interferometer capabilities etc. 
///

public struct PolisTelescope: Codable {

    // item information as defined by POLIS Item
    public var item: PolisItem
    
    // The International Astronomical Union (IAU) Minor Planet Centre (MPC) code
    public var observatoryCode: String?
    
    // root devices of the hierarchy belonging to the telescope
    public var deviceIDs: Set<UUID>
    
    // any POLIS configurations associated with the telescope
    public var configurationIDs: Set<UUID>?
    
    // the parent device of the telescope (if applicable)
    public var parentDevice: UUID?
    
    // the parent observatory of the telescope (if applicable)
    public var parentObservatory: UUID?
    
    // networks that the telescope belongs to (VLBI or otherwise)
    public var networks: [String]?
    
    // indication of if the telescope is capable of Interferometry or Very Long Baseline Interferometry (VLBI)
    public var interferometerCapabilities: Bool?
 
}
