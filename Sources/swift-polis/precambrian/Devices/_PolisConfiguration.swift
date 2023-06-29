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


//MARK: - Configurations -

/// A `POLIS configuration` describes a set of interconnected `POLIS devices`, the way these devices are set up, the dependent properties of the combination of devices and the resulting data type yielded by this configuration.
///
/// In the case of a single telescope, this covers properties that are not fixed and depend on the way the systems described by the `POLIS framework` are set up. Examples may include the focal length of a given focal point and the resulting pixel scale of a camera with a given pixel size attached at that specific focal point.
///
/// In the case of homogeneous arrays (e.g. the Very Large Array), a configuration describes the maximum distance between the antennas, the number of antennas etc. and in telescope networks the distance between the telescopes, and the various inhomogeneous parameters etc.
///
/// Therefore, a configuration has a `POLIS identity`, a configuration type, a resultant data type, devices connected to the configuration, properties of that configuration, and defaults and active labels.
///

public struct PolisConfiguration: Codable {

    public enum ConfigurationType: String, Codable {
        
        // Configuration is for an array of connected telescopes
        case array
        
        // Configuration is for a network of independent telescopes
        case network
        
        // Configuration is for a single telescope
        case telescope
    }
    
    
    // Defines the type of scientific data that is produced by the configuration
    public enum ObservationResultType: String, Codable {

        // 2D Imaging
        case simple2DImage             = "simple_2D_image"
        case multiFilter2DImage        = "multi_filter_2D_image"

        // Spectroscopy
        case singleFibreSpectroscopy   = "single_fibre_spectroscopy"
        case multiFibreSpectroscopy    = "multi_fibre_spectroscopy"
        case integralFieldSpectroscopy = "integral_field_spectroscopy"
        case singleSlitSpectroscopy    = "single_slit_spectroscopy"
        case multiSlitSpectroscopy     = "multi_slit_spectroscopy"
        case radioSpectroscopy         = "radio_spectroscopy"
        case fabryPerotSpectroscopy    = "fabry_perot_spectroscopy"

        // Polarimetry
        case photoPolarimetry          = "photo_polarimetry"
        case spectroPolarimetry        = "spectro_polarimetry"

        // Miscellaneous
        case photographicPlate         = "photographic_plate"
        case radiometry                = "radiometry"
    }

    // defines the parts of the electromagnetic spectrum that the observation is made in
    public enum ElectromagneticCoverage: String, Codable {
        case gammaRay      = "gamma_ray"
        case xRay          = "x_ray"
        case ultraviolet
        case optical
        case infrared
        case subMillimetre = "sub_millimetre"
        case millimetre
        case radio
    }


    // Identity information incl. uuid, reference etc.
    public var identity: PolisIdentity
    
    // type of the specific configuration
    public var configurationType: ConfigurationType
    
    // resulting data type produced by the configuration
    public var observationResultType: ObservationResultType
    
    // the parts of the electromagnetic spectrum that the telescope is capable of observing
    public var emCoverage: [ElectromagneticCoverage]?
    
    // uuids of the associated POLIS devices with the configuration
    public var deviceIDs: [UUID]
    
    // uuid link to the dependent properties on the configuration
    public var configurationSpecificPropertiesID: UUID

    public var availabilityStartTime: Date?
    public var availabilityEndTime: Date?

    public init(identity: PolisIdentity,
                configurationType: ConfigurationType,
                observationResultType: ObservationResultType,
                emCoverage: [ElectromagneticCoverage]?  = nil,
                deviceIDs: [UUID],
                configurationSpecificPropertiesID: UUID,
                availabilityStartTime: Date?            = nil,
                availabilityEndTime: Date?              = nil) {
        self.identity                          = identity
        self.configurationType                 = configurationType
        self.observationResultType             = observationResultType
        self.emCoverage                        = emCoverage
        self.deviceIDs                         = deviceIDs
        self.configurationSpecificPropertiesID = configurationSpecificPropertiesID
        self.availabilityStartTime             = availabilityStartTime
        self.availabilityEndTime               = availabilityEndTime
    }

    public func suggesteдDeviceIDs() -> Set<UUID> { Set<UUID>() } //TODO: Implement me!

}

//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisConfiguration {
    enum CodingKeys: String, CodingKey {
        case identity
        case configurationType                 = "configuration_type"
        case observationResultType             = "observation_result_type"
        case emCoverage                        = "em_coverage"
        case deviceIDs                         = "device_ids"
        case configurationSpecificPropertiesID = "configuration_ids"
        case availabilityStartTime             = "availability_start_time"
        case availabilityEndTime               = "availability_end_time"
    }
}