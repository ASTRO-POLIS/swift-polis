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

public struct PolisTelescope: Codable {
    
    // defines the overall type of the telescope, i.e. how the combined devices function together as a system
    public enum TelescopeType: String, Codable {
        case reflector
        case refractor
        case steerableRadioDish
        case staticRadioDish
        case telephotoLens
        case antenna
        case other
    }
    
    // defines the parts of the electromagnetic spectrum that the telescope is capable of observing
    public enum ElectromagneticCoverage: String, Codable {
        case gammaRay
        case xRay
        case ultraviolet
        case optical
        case infrared
        case submillimetre
        case millimetre
        case radio
    }

    // item information as defined by POLIS Item
    public var item: PolisItem
    
    // type of telescope, i.e. how the combined devices function as an overall system
    public var telescopeType: TelescopeType?
    
    // the parts of the electromagnetic spectrum that the telescope is capable of observing
    public var emCoverage: [ElectromagneticCoverage]?
    
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

//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisTelescope.ElectromagneticCoverage {
    enum CodingKeys: String, CodingKey {
        case gammaRay         = "gamma_ray"
        case xRay             = "x_ray"
        case ultraviolet      = "ultraviolet"
        case optical          = "optical"
        case infrared         = "infrared"
        case submillimeter    = "submillimeter"
        case millimeter       = "millimeter"
        case radio            = "radio"
    }
}

public extension PolisTelescope.TelescopeType {
    enum CodingKeys: String, CodingKey {
        case reflector             = "reflector"
        case refractor             = "refractor"
        case steerableRadioDish    = "steerable_radio_dish"
        case staticRadioDish       = "static_radio_dish"
        case telephotoLens         = "telephoto_lens"
        case antenna               = "antenna"
        case other                 = "other"
    }
}
