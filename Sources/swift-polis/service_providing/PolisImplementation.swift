//===----------------------------------------------------------------------===//
//  PolisImplementation.swift
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

/// `PolisImplementation` encapsulates a specific POLIS API implementation variant by
/// combining three orthogonal properties:
/// - Data format used for encoding/decoding API payloads (`DataFormat`)
/// - Functional scope of the API exposed (`APILevel`)
/// - Concrete semantic version of the implementation (`SemanticVersion`)
///
/// This type is a key piece of discovery and compatibility negotiation between POLIS
/// Service Providers and clients (or other providers). Different clients across iOS,
/// iPadOS, macOS, other platforms, or server-side environments may require different
/// combinations of data format and API capabilities. By publishing a list of
/// supported `PolisImplementation` values, a provider enables:
/// - Client-side selection of a compatible implementation variant
/// - Server-side validation that a requested variant is supported
/// - Clear evolution across breaking and non‑breaking changes via semantic versioning
///
/// Usage notes:
/// - Prefer XML (.xml) for production-grade integrations; JSON ) is often
///   more convenient for rapid prototyping or lightweight clients.
/// - `apiSupport` conveys the functional scope, from static resources only to
///   dynamic status updates and full dynamic scheduling.
/// - `version`  follows Semantic Versioning (see https://semver.org) and is used to
///   compare and select compatible implementations.
/// - Conformance to Codable, Equatable, and Hashable allows easy persistence,
///   transport, and set/dictionary usage, as well as deterministic comparison.
/// - See PolisImplementation.latestSupportedImplementation() to obtain the
///   framework’s default/latest supported variant and
///   PolisImplementation.polisServiceProviderSupports(_:) to check support.
///
///   Provider implementation note:
/// - Every POLIS Service Provider should be able to maintain the correct list of implementation variants for every other
///   `public` or `mirror` provider. Only `experimental` Service Providers should be allowed to implement
///   unsupported implementations.
public struct PolisImplementation: Codable, Equatable, Sendable  {

    /// Defines various POLIS data formats
    ///
    /// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation, XML APIs
    /// are preferred for production-ready code. In contrast, JSON is often easier to use for new development (no need of
    /// schema support) and is often easier to be used within a mobile or a web application. Due to its fragility
    /// JSON-based implementation should be avoided in stable production systems.
    public enum DataFormat: String, Codable, Equatable, Hashable, Sendable {
        /// The provider implements JSON APIs
        case json

        /// The provider implements XML APIs
        case xml
    }

    /// `APILevel` defines the three levels of API support
    ///
    /// POLIS is a complex standard. Its full implementation requires significant efforts, and not all organisations are
    /// able to invest or capable of implementing the full set of APIs. In order to simplify the implementation of POLIS
    /// Providers used by amateur clubs or in education, the standard defines three API levels. The simplest one is
    /// nothing more than a website with static resources.
    public enum APILevel: String, Codable, Equatable, Hashable, Sendable {

        /// The service provider hosts only static data
        case staticData        = "static_data"

        /// If the status of observing facilities is updated manually (e.g. by the admin) or automatically (by using POLIS-defined
        /// APIs), the service provider dynamically propagates the status information.
        case dynamicStatus     = "dynamic_status"

        /// The service provider can dynamically schedule observations (for observing facilities that implement this functionality) and
        /// manage complex observation scheduling.
        case dynamicScheduling = "dynamic_scheduling"
    }

    //MARK: Static methods

    /// Returns the most recent POLIS implementation variant supported by the framework.
    ///
    /// This helper scans the framework’s declared list of supported implementations
    /// (`PolisConstants.frameworkSupportedImplementation`) and selects the one with
    /// the highest semantic version. The returned value can be used as a sensible
    /// default when a caller has no specific preference, or when negotiating
    /// capabilities with a POLIS Service Provider.
    ///
    /// Returns:
    /// - The `PolisImplementation` with the highest `SemanticVersion` among the
    ///   framework-supported implementations.
    ///
    /// Important:
    /// - The framework must declare at least one supported implementation in
    ///   `PolisConstants.frameworkSupportedImplementation`. If the list is empty,
    ///   this method will trigger a runtime failure.
    ///
    /// See also:
    /// - `PolisImplementation.polisServiceProviderSupports(_:)` for testing whether
    ///   a specific variant is supported.
    /// - `SemanticVersion` for details on how version ordering is determined.
    public static func latestSupportedImplementation() -> PolisImplementation {
        var currentImplementation: PolisImplementation?

        for info in polisFrameworkSupportedImplementation {
            if currentImplementation != nil {
                if (currentImplementation!.version > info.version) {
                    currentImplementation = info
                }
            }
            else { currentImplementation = info }
        }

        return currentImplementation!
    }

    /// Returns whether the current framework supports a specific POLIS implementation variant.
    ///
    /// This method checks the provided `implementation` against the framework’s declared list of
    /// supported variants (`PolisConstants.frameworkSupportedImplementation`). It is useful when
    /// negotiating compatibility between a client and a POLIS Service Provider, or when validating
    /// that a requested combination of data format, API level, and semantic version is available.
    ///
    /// - Parameter implementation: The concrete `PolisImplementation` (data format, API level,
    ///   and semantic version) to test for support.
    /// - Returns: `true` if the exact implementation is supported; otherwise, `false`.
    /// - Important: The match is exact. If you need semantic compatibility (e.g., any patch
    ///   version within a compatible range), perform additional version checks using `SemanticVersion`.
    public static func polisServiceProviderSupports(_ implementation: PolisImplementation) -> Bool {
        for anImplementation in polisFrameworkSupportedImplementation {
            if implementation == anImplementation { return true }
        }
        return false
    }

    //MARK: - Public APIs -
    public var dataFormat: DataFormat
    public var apiSupport: APILevel
    public var version: SemanticVersion

    /// Creates a new POLIS implementation descriptor by combining data format, API level, and semantic version.
    ///
    /// Use this initialiser to describe a concrete variant of the POLIS API that a client or
    /// service provider supports or prefers. The combination of parameters is used during
    /// discovery and compatibility negotiation.
    ///
    /// - Parameters:
    ///   - dataFormat: The payload encoding format used by the implementation. Defaults to `.json`.
    ///                 Prefer `.xml` for production-grade integrations; `.json` can be convenient
    ///                 for prototyping or lightweight clients.
    ///   - apiSupport: The functional scope of the exposed API (e.g., static resources only,
    ///                 dynamic status updates, or full dynamic scheduling). Defaults to `.staticData`.
    ///   - version: The semantic version of the implementation, used to compare and select compatible
    ///              variants following Semantic Versioning rules.
    public init(dataFormat: DataFormat = .json, apiSupport: APILevel = .staticData, version: SemanticVersion) {
        self.dataFormat = dataFormat
        self.apiSupport = apiSupport
        self.version    = version
    }
}

//MARK: - Comparable
extension PolisImplementation.APILevel: Comparable {
    //TODO: $$$ZH This method is obviously wrong!
    public static func < (left: PolisImplementation.APILevel, right: PolisImplementation.APILevel) -> Bool {
        if      (left == .staticData)        && (left == right)               { return true }
        else if (left == .dynamicStatus)     && (right == .dynamicScheduling) { return true } //TODO: Add dynamic options!
        else if (left == .dynamicScheduling) && (right == .dynamicScheduling) { return true } //TODO: Add dynamic options!

        return false
    }
}


//MARK: - This extension is needed for supporting a well formatted JSON API
public extension PolisImplementation {
    enum CodingKeys: String, CodingKey {
        case dataFormat = "data_format"
        case apiSupport = "api_support"
        case version
    }
}

//MARK: This makes `PolisImplementation` Equatable
extension PolisImplementation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(apiSupport)
        hasher.combine(version.description)
    }
}
