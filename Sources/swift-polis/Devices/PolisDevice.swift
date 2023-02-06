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

public protocol DeviceDescribable: Codable {
    
}

public struct PolisDevice: Codable, Identifiable {

    public enum DeviceType: String, Codable {

        //MARK: POLIS v.1.0.
        // Optical telescope related (mostly ground-based)
        case mirror            = "Mirror"


        // Suggested device types for future versions of the standard
        case enclosure         = "Enclosure"
        case mount             = "Mount"
        case antennaFrame      = "AntennaFrame"
        case telescope         = "Telescope"
        case ota               = "OTA"
        case lens              = "Lens"
        case camera            = "Camera"
        case shutter           = "Shutter"
        case detector          = "Detector"
        case filterWheel       = "FilterWheel"
        case filter            = "Filter"
        case sensor            = "Sensor"
        case spectrograph      = "Spectrograph"
        case grating           = "Grating"
        case prism             = "Prism"
        case bolometer         = "Bolometer"
        case receiver          = "Receiver"
        case photomultiplier   = "PhotomultiplierTube"
        case photographicPlate = "PhotographicPlate"
        case eyePiece          = "EyePiece"
        case aoSystem          = "AOSystem"
        case laser             = "Laser"
        case beamSplitter      = "BeamSplitter"
        case wavefrontSensor   = "WavefrontSensor"
        case derotator         = "Derotator"
        case weatherStation    = "WeatherStation"
        case skyCamera         = "SkyCamera"
        case webcam            = "Webcam"
        case screen            = "Screen"
        case generator         = "Generator"
        case solarPanel        = "SolarPanel"
        case battery           = "Battery"
        case ups               = "UPS"
        case satellitePlatform = "SatellitePlatform"
        case rover             = "Rover"
        case lander            = "Lander"
        case balloon           = "Balloon"
        case spaceStation      = "SpaceStation"
        case plane             = "Plane"
    }


    //MARK: - POLIS mode of operation
    
    public enum ModeOfOperation: String, Codable {
        case manual
        case manualWithAutomatedDetector
        case manualWithAutomatedDetectorAndScheduling
        case autonomous
        case remote
        case mixed                                       // e.g. in case of Network
        case other
        case unknown
    }

    public var item: PolisItem
    public var type: DeviceType
    public var modeOfOperation: ModeOfOperation
    public var deviceSpecificPropertiesID: UUID
    public var additionalPropertiesID: UUID?

    /// Device administrator's suggested sub-devices
    ///
    /// It is the responsibility of the client software to decide to load or reject these sub-devices. ``PolisImplementationInfo`` implements methods to
    /// support the client software to make the loading decision, but the POLIS standard just recommends a device hierarchy without strictly requiring it. There are
    /// legit cases when the suggested hierarchy does not fit complexity of astronomical observing stations.
    public var suggestedSubDeviceIDs: Set<UUID>
    public var subDevices: Set<UUID>

    public var id: UUID { item.identity.id }

    public init(item: PolisItem,
                type: DeviceType,
                modeOfOperation: ModeOfOperation  = .unknown,
                deviceSpecificPropertiesID: UUID,
                additionalPropertiesID: UUID?     = nil,
                suggestedSubDeviceIDs: Set<UUID>  = Set<UUID>(),
                subDevices: Set<UUID>             = Set<UUID>()) {
        self.item                       = item
        self.type                       = type
        self.modeOfOperation            = modeOfOperation
        self.deviceSpecificPropertiesID = deviceSpecificPropertiesID
        self.additionalPropertiesID     = additionalPropertiesID
        self.suggestedSubDeviceIDs      = suggestedSubDeviceIDs
        self.subDevices                 = subDevices
    }

}


//MARK: - Type extensions -

public extension PolisDevice.ModeOfOperation {
    enum CodingKeys: String, CodingKey {
        case manual
        case manualWithAutomatedDetector              = "manual_with_automated_detector"
        case manualWithAutomatedDetectorAndScheduling = "manual_with_automated_detector_and_scheduling"
        case autonomous
        case mixed
        case other
        case unknown
    }
}

public extension PolisDevice {
    enum CodingKeys: String, CodingKey {
        case item
        case type
        case modeOfOperation       = "mode_of_operation"
        case deviceSpecificPropertiesID          = "properties_id"
        case additionalPropertiesID
        case suggestedSubDeviceIDs = "suggested_sub_device_ids"
        case subDevices            = "sub_devices"
    }
}
