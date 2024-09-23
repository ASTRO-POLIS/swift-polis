//===----------------------------------------------------------------------===//
//  PolisConstants.swift
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
import SoftwareEtudesUtilities

public struct PolisConstants {

    /// This is the first and only POLIS service provider (and domain) that is (almost) guaranteed to be a valid public POLIS service provider.
    ///
    /// This constant defines the URL to the initial POLIS Service Provider. `testBigBangPolisDomain` is an experimental domain that is used to test new
    /// POLIS development and is guaranteed to exit as well.
    ///
    /// Software packages trying for the first time to connect to a POLIS service provider should use these constants. In the future there might be (hopefully) many
    /// more service providers, but an initial search is mostly guaranteed to be successful if `bigBangPolisDomain` is used.
    public static let bigBangPolisDomain     = "https://polis.observer"
    public static let testBigBangPolisDomain = "https://test.polis.observer"

    /// All references should start with this string
    public static let polisReferencePrefix   = "ref://"

    /// A list of supported implementations for this concrete framework.
    ///
    /// Until we have a stable version there should be only one supported version. After version 1.0 of the standard is
    /// released, we should start supporting past versions.
    public static var frameworkSupportedImplementation: [PolisImplementation] =
    [
        PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                            apiSupport: PolisImplementation.APILevel.staticData,
                            version: SemanticVersion(with: "0.2.0-alpha.1")!
                           ),
    ]

}
