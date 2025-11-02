//===----------------------------------------------------------------------===//
//  PolisConstants.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
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

/// As the name suggests, `PolisConstants` encapsulates global constants used by this framework.
///
/// **Note:** some of these constants are NOT part of the POLIS standard. They are used only within
/// this framework.
public struct PolisConstants {
    
    /// Used when we need a required name for an object, but the name is unknown at the time of creation
    public static let unknownObject = "<unknown>"

    /// This is the first and only POLIS service provider (and domain) that is (almost) guaranteed to be a valid
    /// public POLIS service provider.
    ///
    /// Software packages trying for the first time to connect to a POLIS service provider should use this
    /// URL. In the future there might be (hopefully) many more service providers, but an initial search
    /// is mostly guaranteed to be successful if `bigBangPolisDomain` is used.
    public static let bigBangPolisDomain           = "https://polis.observer"

    /// This constant defines the URL to the initial POLIS Test Service Provider.
    ///
    /// `testBigBangPolisDomain` is an experimental domain that is used to test new POLIS
    /// features and is guaranteed to exit as well.
    public static let testBigBangPolisDomain       = "https://test.polis.observer"

    /// This file is not part of the POLIS standard, but it is needed if `swift-polis` is used to manage
    /// the POLIS Provider. It is supposed to be in the folder that contains the `../polis/` root folder.
    public static let polisLocalConfigFileName     = "polis_config.json"

    /// The key for finding auxiliaryServiceHost
    ///
    /// See ``PolisReference``
    public static let auxiliaryServiceHostsPushKey = "ServiceHostsPushKey"
}

/// A list of supported implementations for this concrete framework.
///
/// Until we have a stable version there should be only one supported version. After version 1.0 of the
/// standard is released, we should start supporting past versions.
nonisolated(unsafe) public let polisFrameworkSupportedImplementation: [PolisImplementation] =
[
    PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                        apiSupport: PolisImplementation.APILevel.staticData,
                        version: SemanticVersion(with: "0.1.0-alpha.1")!
                       ),
]
