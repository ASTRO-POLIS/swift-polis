//===----------------------------------------------------------------------===//
//  PolisConstants.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2026 Tuparev Technologies and the ASTRO-POLIS project
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

/// `PolisConstants` is a namespace struct that encapsulates the global constants and shared configuration values used by the POLIS framework.
///
/// This struct provides well-known values such as language codes, placeholder object names, primary service provider URLs, and supported implementation
/// details. Its constants are intended for use throughout the framework to ensure consistency, maintainability, and clear separation between framework-specific
/// configuration and the POLIS protocol standard.
public struct PolisConstants: Sendable {

    /// The default language code for localised texts used throughout the framework.
    ///
    /// This constant specifies the default language as English (`"en"`), ensuring that all user-facing messages, labels, and other localised resources default to
    /// English when a specific localisation is not provided or detected. Applications built with his framework should use this value when a language code is required
    ///  but not specified.
    public static let defaultLanguageCode          = "en"

    /// A placeholder name for an object whose actual name is unknown at creation time.
    ///
    /// Use this constant when an object requires a non-optional name but its true name is unavailable or not yet determined.
    ///
    /// - Note: This value is intended for temporary use and should be replaced with the actual name when it becomes known.
    public static let unknownObject                = "<unknown>"

    /// The canonical URL of the primary public POLIS service provider.
    ///
    /// `bigBangPolisDomain` represents the default, well-known entry point for connecting to the POLIS network. This domain is (almost) guaranteed to be
    ///  available and is recommended as the initial target for clients and applications attempting to discover or interact with a POLIS service provider for the
    ///  first time.
    ///
    /// - Note: While this is the reference provider domain, future versions of the POLIS network may include additional service providers. Clients should allow
    ///         for configuration and discovery of alternate domains when appropriate.
    public static let bigBangPolisDomain           = "https://polis.observer"

    /// The canonical URL for the POLIS Test Service Provider.
    ///
    /// `testBigBangPolisDomain` points to a dedicated test environment for the POLIS network, allowing developers and integrators to experiment with new
    /// features and perform integration testing without impacting production data or services. This domain is persistent and is guaranteed to be available for public
    /// use.
    ///
    /// - Note: Use this domain when developing or testing against the POLIS protocol, rather than the production environment.
    ///         For production use, see ``bigBangPolisDomain``.
    public static let testBigBangPolisDomain       = "https://test.polis.observer"

    /// An array of supported ``PolisImplementation`` instances for this framework.
    ///
    /// This array enumerates all POLIS implementations currently supported by this framework, each described by its data format, API support level, and semantic
    /// version. Until a stable version (1.0) is released, only a single, latest experimental implementation will be present. After release, historical implementations
    /// may be added to allow for backward compatibility and migration.
    ///
    /// - Note: The first element is considered the baseline implementation, and the method
    ///   ``latestPolisFrameworkSupportedImplementation()`` returns the one with the highest version.
    public static let polisFrameworkSupportedImplementations: [PolisImplementation] =
    [
        PolisImplementation(dataFormat: PolisImplementation.DataFormat.json,
                            apiSupport: PolisImplementation.APILevel.staticData,
                            version: SemanticVersion(with: "0.1.0-alpha.1")!
                           ),
    ]

    /// Returns the latest supported POLIS implementation by this framework.
    ///
    /// This method inspects the ``polisFrameworkSupportedImplementations`` array and returns the implementation with the highest semantic version
    /// number. This is useful for determining which version of the POLIS standard is currently supported as the most recent by this framework.
    ///
    /// - Returns: The ``PolisImplementation`` instance representing the latest supported implementation.
    /// - Note: The method force unwraps the result and assumes that ``polisFrameworkSupportedImplementations`` is never empty.
    public func latestPolisFrameworkSupportedImplementation() -> PolisImplementation {
        PolisConstants.polisFrameworkSupportedImplementations.max(by: { $0.version < $1.version })!
    }
    
    /// An `ISO8601DateFormatter` instance configured with `.withInternetDateTime` formatting options.
    ///
    /// This formatter is scoped to the main actor and is intended for consistent parsing and generation of ISO 8601 date strings throughout the framework.
    /// Using a shared, static formatter helps minimise performance costs associated with creating new formatter instances and ensures uniform date formatting.
    ///
    /// - Note: Access to this formatter is restricted to the main actor to ensure thread safety, as `DateFormatter` and related formatters are not
    ///         inherently thread-safe.
    @MainActor static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
