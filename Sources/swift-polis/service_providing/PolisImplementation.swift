//===----------------------------------------------------------------------===//
//  PolisImplementation.swift
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

/// `PolisImplementation` combines supported data format, API level, and version in a single struct
///
/// This information is an integral part of the POLIS Service Provider. It is assumed that different clients on
/// different platforms depend on different combinations of data format, API level, and version. Nevertheless, each
/// client should be able to search for a service provider that supports its concrete requirements. In addition, every
/// POLIS Service Provider should be able to maintain the correct list of implementation variants for every other
/// `public` or `mirror` provider. Only `experimental` Service Providers should be allowed to implement unsupported
/// implementations.
///
/// For a complete description Semantic Version see [Semantic Versioning](https://semver.org)
public struct PolisImplementation: Codable, Equatable  {

    /// Defines various POLIS data formats
    ///
    /// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation, XML APIs
    /// are preferred for production-ready code. In contrast, JSON is often easier to use for new development (no need of
    /// schema support) and is often easier to be used within a mobile or a web application. Due to its fragility
    /// JSON-based implementation should be avoided in stable production systems.
    public enum DataFormat: String, Codable, Equatable, Hashable {
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
    public enum APILevel: String, Codable, Equatable, Hashable {

        /// The service provider hosts only static data
        case staticData        = "static_data"

        /// If the status of observing facilities is updated manually (e.g. by the admin) or automatically (by using POLIS-defined
        /// APIs), the service provider dynamically propagates the status information.
        case dynamicStatus     = "dynamic_status"

        /// The service provider can dynamically schedule observations (for observing facilities that implement this functionality) and
        /// manage complex observation scheduling.
        case dynamicScheduling = "dynamic_scheduling"
    }

    /// This is used to select the oldest supported implementation info in order to provide default data whenever needed
    ///
    ///  **Note:** The method assumes that the POLIS Service Provider implements at least one Implementation. Otherwise bad things will happen
    public static func oldestSupportedImplementation() -> PolisImplementation {
        var currentImplementation: PolisImplementation?

        for info in PolisConstants.frameworkSupportedImplementation {
            if currentImplementation != nil {
                if (currentImplementation!.version > info.version) &&
                    (currentImplementation!.apiSupport > info.apiSupport) &&
                    ((currentImplementation!.dataFormat == .xml) && (info.dataFormat == .json)) {
                    currentImplementation = info
                }
            }
            else { currentImplementation = info }
        }

        return currentImplementation!
    }


    public var dataFormat: DataFormat
    public var apiSupport: APILevel
    public var version: SemanticVersion

    public init(dataFormat: DataFormat, apiSupport: APILevel, version: SemanticVersion) {
        self.dataFormat = dataFormat
        self.apiSupport = apiSupport
        self.version    = version
    }


}

//MARK: - Type extensions -
extension PolisImplementation.APILevel: Comparable {
    public static func < (left: PolisImplementation.APILevel, right: PolisImplementation.APILevel) -> Bool {
        if      (left == .staticData)    && (left != right)               { return true }
        else if (left == .dynamicStatus) && (right == .dynamicScheduling) { return true }

        return false
    }
}


// This extension is needed for supporting a well formatted JSON API
public extension PolisImplementation {
    enum CodingKeys: String, CodingKey {
        case dataFormat = "data_format"
        case apiSupport = "api_support"
        case version
    }
}

// This makes `PolisImplementation` Equatable
extension PolisImplementation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataFormat)
        hasher.combine(apiSupport)
        hasher.combine(version.description)
    }
}

