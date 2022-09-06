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
        case camera            = "Camera"
        case shutter           = "Sutter"
        case detector          = "Detector"
        case sensor            = "Sensor"
        case spectrograph      = "Spectrograph"
        case grating           = "Grating"
        case filterWheel       = "FilterWheel"
        case filter            = "Filter"
        case eyePiece          = "EyePiece"
        case derotator         = "Derotator"
        case weatherStation    = "WeatherStation"
        case ups               = "UPS"
        case webcam            = "Webcam"
        case skyCamera         = "SkyCamera"
        case screen            = "Screen"
        case generator         = "Generator"
        case antena            = "Antena"
        case radioDish         = "RadioDish"
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

    public enum SubDeviceOperationError: Error {
        case subDeviceNotFound                      // Trying to remove a non-existing sub-device
        case attemptToAddSubDeviceOfTypeNotAllowed  // e.g. try to add Telescope to a Weather Station
    }

    public var item: PolisItem
    public var type: DeviceType
    public var modeOfOperation: ModeOfOperation
    public var propertiesID: UUID

    public var id: UUID { item.identity.id }

    public init(item: PolisItem, type: DeviceType, modeOfOperation: ModeOfOperation = .unknown, propertiesID: UUID) {
        self.item            = item
        self.type            = type
        self.modeOfOperation = modeOfOperation
        self.propertiesID    = propertiesID
    }

    // VERY IMPORTANT NOTE: The order of elements in `_subDeviceIDs` and `_subDevices` MUST be the same!
    // This is done for optimisation reasons. If this rule is not follow, what will follow is a gigantic mess!

    private var _subDeviceIDs = [UUID]()
    public func subDeviceIDs() -> [UUID] { _subDeviceIDs }


    private var _subDevices = [PolisDevice]()

    public mutating func add(subDevice: PolisDevice) throws {
        if PolisImplementationInfo.canDevice(ofType: subDevice.type, beSubDeviceOfType: self.type, for: frameworkSupportedImplementation.last!) {
            let dID = subDevice.id

            _subDeviceIDs.append(dID)
            _subDevices.append(subDevice)
        }
        else { throw SubDeviceOperationError.attemptToAddSubDeviceOfTypeNotAllowed }
    }

    public mutating func remove(subDevice: PolisDevice) throws {
        let dID = subDevice.id

        guard let index = _subDeviceIDs.firstIndex(of: dID) else { throw SubDeviceOperationError.subDeviceNotFound }

        _subDeviceIDs.remove(at: index)
        _subDevices.remove(at: index)
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

