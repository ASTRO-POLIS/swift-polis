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
        case simple2DImage
        case multiFilter2DImage
        case photometry
        case spectrography

        //TODO: Astronomers should define the entire list!
    }

    public var observationResultType: ObservationResultType
    public var item: PolisItem
    public var deviceIDs: [UUID]
    public var isDefault = true
}

//MARK: - Making types Codable and CustomStringConvertible -

public extension PolisConfiguration.ObservationResultType {
    enum CodingKeys: String, CodingKey {
        case simple2DImage      = "simple_2D_image"
        case multiFilter2DImage = "multi_filter_2D_image"
        case photometry
        case spectrography
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
