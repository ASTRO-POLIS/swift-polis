//===----------------------------------------------------------------------===//
//  PolisObservatory.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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

public struct PolisObservatory {

    public enum PolisObservatoryType: String, Codable {
        case opticalTelescope
        case radioDish
        case radioDishArray
        case radioAntenna
        case radioAntennaArray
        case cherenkovTelescopeArray
        case opticalInterferometer
        case radioInterferometer
        case neutrinoDetector
        case gravitationalWaveDetector
        case multiSensorPlatform
        case other
        case unknown
    }

    // Identification and type
    public var item: PolisItem
    public var primaryElectromagneticSpectrumCoverage: PolisElectromagneticSpectrumCoverage
    public var primaryObservatoryType: PolisObservatoryType

    public var configurationIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

}


//MARK: - Type extensions -


public extension PolisObservatory.PolisObservatoryType {
    enum CodingKeys: String, CodingKey {
        case opticalTelescope          = "optical_telescope"
        case radioDish                 = "radio_dish"
        case radioDishArray            = "radio_dish_array"
        case radioAntenna              = "radio_antenna"
        case radioAntennaArray         = "radio_antenna_array"
        case cherenkovTelescopeArray   = "cherenkov_telescope_array"
        case opticalInterferometer     = "optical_interferometer"
        case radioInterferometer       = "radio_interferometer"
        case neutrinoDetector          = "neutrino_detector"
        case gravitationalWaveDetector = "gravitational_wave_detector"
        case multiSensorPlatform       = "multi_sensor_platform"
        case other
        case unknown
    }
}
