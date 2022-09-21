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

public protocol DeviceDescribable: Codable {
    
}

public struct PolisDevice: Codable, Identifiable {

    public enum DeviceType: String, Codable {

        //TODO: Sort them logically!

        case telescope         = "Telescope"
        case mount             = "Mount"
        case ota               = "OTA"
        case enclosure         = "Enclosure"
        case mirror            = "Mirror"
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
        case eyePiece          = "EyePiece"
        case derotator         = "Derotator"
        case weatherStation    = "WeatherStation"
        case ups               = "UPS"
        case webcam            = "Webcam"
        case skyCamera         = "SkyCamera"
        case screen            = "Screen"
        case generator         = "Generator"
        case antenna           = "Antenna"
        case staticDish        = "StaticDish"
        case steerableDish     = "SteerableDish"
        case bolometer         = "Bolometer"
        case reciever          = "Reciever"
        case photomultiplier   = "PhotomultiplierTube"
        case satellitePlatform = "SatellitePlatform"
        case solarPanel        = "SolarPanel"
        case battery           = "Battery"
        case rover             = "Rover"
        case lander            = "Lander"
        case balloon           = "Balloon"
        case spaceStation      = "SpaceStation"
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
    public var propertiesID: UUID

    /// Device administrator's suggested sub-devices
    ///
    /// It is the responsibility of the client software to decide to load or reject these sub-devices. ``PolisImplementationInfo`` implements methods to
    /// support the client software to make the loading decision, but the POLIS standard just recommends a device hierarchy without strictly requiring it. There are
    /// legit cases when the suggested hierarchy does not fit complexity of astronomical observing stations.
    public var proposedSubDeviceIDs: [UUID]?

    public var id: UUID { item.identity.id }

    public init(item: PolisItem, type: DeviceType, modeOfOperation: ModeOfOperation = .unknown, propertiesID: UUID, proposedSubDeviceIDs: [UUID]? = nil) {
        self.item                 = item
        self.type                 = type
        self.modeOfOperation      = modeOfOperation
        self.propertiesID         = propertiesID
        self.proposedSubDeviceIDs = proposedSubDeviceIDs
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
        case modeOfOperation      = "mode_of_operation"
        case propertiesID         = "properties_id"
        case proposedSubDeviceIDs = "proposed_sub_device_ids"
    }
}
