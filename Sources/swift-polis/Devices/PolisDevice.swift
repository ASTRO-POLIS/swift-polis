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
        case adaptiveOpticsSystem = "adaptive_optics_system"
        case antenna
        case autoguider                               // RTML
        case beamSplitter         = "beam_splitter"
        case bolometer
        case camera                                   // RTML
        case derotator
        case dimm                                     // RTML
        case enclosure
        case eyePiece             = "eye_piece"
        case filterWheel          = "filter_wheel"    // RTML
        case filter                                   // RTML
        case wavePlate            = "wave_plate"      // RTML
        case laser
        case lens                                     // RTML
        case mirror                                   // RTML
        case mount
        case ota
        case other                                    // RTML - no device specific properties
        case photomultiplier
        case polarimeter                              // RTML
        case radioReceiver        = "radio_receiver"
        case screen                                   // No device specific properties
        case shutter                                  // RTML
        case skyMonitor           = "sky_monitor"     // RTML
        case spectrograph                             // RTML
        case upsSystem            = "ups_system"
        case webCamera            = "web_camera"      // RTML
        case weatherStation       = "weather_station" // RTML
    }

    public var item: PolisItem
    public var type: DeviceType
    public var deviceSpecificPropertiesID: UUID
    public var additionalPropertiesID: UUID?
    public var url: URL?
    public var scientificObjectives: String?
    public var notes: String?

        
    /// Device administrator's suggested sub-devices
    ///
    /// It is the responsibility of the client software to decide to load or reject these sub-devices. ``PolisImplementationInfo`` implements methods to
    /// support the client software to make the loading decision, but the POLIS standard just recommends a device hierarchy without strictly requiring it. There are
    /// legit cases when the suggested hierarchy does not fit complexity of astronomical observing stations.
    public var subDevices: Set<UUID>?

    public var id: UUID { item.identity.id }
    
    // POLIS configurations associated with the device
    public var configurationIDs: Set<UUID>?

    public init(item: PolisItem,
                type: DeviceType,
                deviceSpecificPropertiesID: UUID,
                additionalPropertiesID: UUID?     = nil,
                suggestedSubDeviceIDs: Set<UUID>? = nil,
                url: URL?                         = nil,
                scientificObjectives: String?     = nil,
                notes: String?                    = nil,
                subDevices: Set<UUID>?            = nil) {
        self.item                       = item
        self.type                       = type
        self.deviceSpecificPropertiesID = deviceSpecificPropertiesID
        self.additionalPropertiesID     = additionalPropertiesID
        self.url                        = url
        self.scientificObjectives       = scientificObjectives
        self.notes                      = notes
        self.subDevices                 = subDevices
    }

    public func suggestedSubDeviceIDs() -> Set<UUID> { Set<UUID>() } //TODO: Implement me!

}


//MARK: - Type extensions -

public extension PolisDevice {
    enum CodingKeys: String, CodingKey {
        case item
        case type
        case deviceSpecificPropertiesID = "device_specific_properties_id"
        case additionalPropertiesID     = "additional_properties_id"
        case url
        case scientificObjectives       = "scientific_objectives"
        case notes
        case subDevices                 = "sub_devices"
    }
}
