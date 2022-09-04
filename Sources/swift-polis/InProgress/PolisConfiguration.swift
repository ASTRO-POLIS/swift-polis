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

public enum PolisObservationResultType: String, Codable {
    case simple2DImage
    case multiFilter2DImage
    case photometry
    case spectrography

    //TODO: Astronomers should define the entire list!
}

public struct PolisConfiguration: Codable {
    public var observationResulType: PolisObservationResultType
    public var item: PolisItem
    public var deviceIDs: [UUID]
    public var isDefault = true
}
