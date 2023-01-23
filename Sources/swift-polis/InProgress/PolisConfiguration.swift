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


public struct PolisConfiguration: Codable {

    public enum ObservationResultType: String, Codable {

        // 2D Imaging
        case simple2DImage
        case multiFilter2DImage

        // Spectrography
        case singleFibreSpectrography
        case multiFibreSpectrography
        case integralFieldSpectrography
        case singleSlitSpectrography
        case multiSlitSpectrography
        case radioSpectroscopy

        // Polarimetry
        case photoPolarimetry
        case spectrePolarimetry

        // Miscellaneous
        case fabryPerot          //TODO: What is this? Astronomers, please explain
        case photographicPlate
    }

    public var observationResultType: ObservationResultType
    public var item: PolisItem
    public var deviceIDs: [UUID]
    public var isDefault = true
    public var isActive  = true
}

//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisConfiguration.ObservationResultType {
    enum CodingKeys: String, CodingKey {


        // 2D Imaging
        case simple2DImage              = "simple_2D_image"
        case multiFilter2DImage         = "multi_filter_2D_image"

        // Spectrography
        case singleFibreSpectrography   = "single_fibre_spectroscopy"
        case multiFibreSpectrography    = "multi_fibre_spectroscopy"
        case integralFieldSpectrography = "integral_field_spectroscopy"
        case singleSlitSpectrography    = "single_slit_spectroscopy"
        case multiSlitSpectrography     = "multi_slit_spectroscopy"
        case radioSpectroscopy          = "radioSpectroscopy"

        // Polarimetry
        case photoPolarimetry           = "photo_polarimetry"
        case spectrePolarimetry         = "spectre_polarimetry"

        // Miscellaneous
        case fabryPerot                 = "fabry_perot"
        case photographicPlate          = "photographic_plate"
    }
}

public extension PolisConfiguration {
    enum CodingKeys: String, CodingKey {
        case observationResultType = "observation_result_type"
        case item
        case deviceIDs             = "device_ids"
        case isDefault             = "is_default"
    }
}
