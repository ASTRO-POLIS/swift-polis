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
import SoftwareEtudes

/// This is the first and only domain that is guaranteed to be a valid POLIS service provider.
///
/// There might be (hopefully) many more service providers, but one can start the domain search always from the POLIS'
/// Big Bang.
public let bigBangPolisDomain = "https://polis.onserver"



//MARK: - Supported POLIS Data formats, e.g. JSON, XML, ..., levels of API support and versions -

/// Defines various POLIS data formats
///
/// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation, XML APIs
/// are preferred for production-ready code. In contrast, JSON is often easier to use for new development (no need of
/// schema support) and is often easier to be used within a mobile or a web applications. Due to its fragility
/// JSON-based implementation should be avoided in stable production systems.
///
/// The type implements the `Equatable` and the `Codable` protocols
public enum PolisDataFormat: String, Codable, Equatable, Hashable {
    /// The provider implements JSON APIs
    case json

    /// The provider implements XML APIs
    case xml
}

/// `PolisAPISupport` defines the three levels of API support
public enum PolisAPISupport: String, Codable, Equatable, Hashable {

    /// The service provider hosts only static (most probably saved in text files) data
    case staticData        = "static_data"

    /// If the status of observing sites is updated manually (e.g. by the admin) or automatically (by using POLIS-defined
    /// APIs), the service provider dynamically propagates this information.
    case dynamicStatus     = "dynamic_status"

    /// The service provider can dynamically schedule observations (for sites that implement this functionality) and
    /// manage complex `Level 2` observing projects.
    case dynamicScheduling = "dynamic_scheduling"
}

//MARK: - Directions

/// A list of 16 rough directions
///
/// Rough direction could be used when it is not important to know or impossible to measure the exact direction.
/// Examples include the wind direction, or the orientations of the doors of clamshell enclosure.
public enum PolisRoughDirection: String, Codable {
    case north          = "N"
    case northNorthEast = "NNE"
    case northEast      = "NE"
    case eastNorthEast  = "ENE"

    case east           = "E"
    case eastSouthEast  = "ESE"
    case southEast      = "SE"
    case southSouthEast = "SSE"

    case south          = "S"
    case southSouthWest = "SSW"
    case southWest      = "SW"
    case westSouthWest  = "WSW"

    case west           = "W"
    case westNorthWest  = "WNW"
    case northWest      = "NW"
    case northNorthWest = "NNW"
}

/// `PolisDirection` is used to represent either a rough direction (of 16 possibilities) or exact direction in degree
/// represented as a double number (e.g. 57.349)
public enum PolisDirection: Codable {
    case rough(direction: PolisRoughDirection)
    case exact(degree: Double)
}

//MARK: - POLIS version management

/// `PolisSupportedImplementation` combines supported data format, API level, and version in a single struct
///
/// This information is an integral part of the basic POLIS service provider. It is assumed that different clients on
/// different platform depend on different combinations of data format, API level, and version. Nevertheless, each
/// client should be able to search for a service provider that supports its concrete requirements. In addition, every
/// POLIS service provider should be able to maintain the correct list of implementation variants for every other
/// `public` or `mirror` provider. Only `experimental` service providers should be allowed to implement unsupported
/// implementations.
///
///  For complete description Semantic Version consult [Semantic Versioning](https://semver.org)
public struct PolisSupportedImplementation: Codable, Equatable {
    public let dataFormat: PolisDataFormat
    public let apiSupport: PolisAPISupport
    public let version: SemanticVersion

    public init(dataFormat: PolisDataFormat, apiSupport: PolisAPISupport, version: SemanticVersion) {
        self.dataFormat = dataFormat
        self.apiSupport = apiSupport
        self.version    = version
    }
}

/// This is a list of supported implementations for this concrete framework.
public var frameworkSupportedImplementation: [PolisSupportedImplementation] =
[
    PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!),
]


//MARK: - Type extensions -

// This extension is needed for supporting a well formatted JSON API
public extension PolisSupportedImplementation {
    enum CodingKeys: String, CodingKey {
        case dataFormat = "data_format"
        case apiSupport = "api_support"
        case version
    }
}

extension PolisSupportedImplementation: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataFormat)
        hasher.combine(apiSupport)
        hasher.combine(version.description)
    }
}
