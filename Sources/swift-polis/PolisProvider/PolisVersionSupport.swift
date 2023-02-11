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
import SoftwareEtudesUtilities

/// This is the first and only POLIS service provider (and domain) that is (almost) guaranteed to be a valid POLIS
/// service provider.
///
/// This constant defines the URL to the initial POLIS Service Provider.
///
/// Software packages trying for the first time to connect to a POLIS service provider should use this constant. In
/// the future there might be (hopefully) many more service providers, but initial search is mostly guaranteed to be
/// successful if `bigBangPolisDomain` is used.
public let bigBangPolisDomain = "https://polis.observer"



//MARK: - POLIS version management -

/// `PolisImplementationInfo` combines supported data format, API level, and version in a single struct
///
/// This information is an integral part of the POLIS service provider. It is assumed that different clients on
/// different platforms depend on different combinations of data format, API level, and version. Nevertheless, each
/// client should be able to search for a service provider that supports its concrete requirements. In addition, every
/// POLIS service provider should be able to maintain the correct list of implementation variants for every other
/// `public` or `mirror` provider. Only `experimental` service providers should be allowed to implement unsupported
/// implementations.
///
///  For complete description Semantic Version see [Semantic Versioning](https://semver.org)
public struct PolisImplementationInfo: Codable, Equatable {

    //MARK: - Supported POLIS Data formats, (e.g. JSON, XML) and levels of API

    /// Defines various POLIS data formats
    ///
    /// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation, XML APIs
    /// are preferred for production-ready code. In contrast, JSON is often easier to use for new development (no need of
    /// schema support) and is often easier to be used within a mobile or a web applications. Due to its fragility
    /// JSON-based implementation should be avoided in stable production systems.
    public enum DataFormat: String, Codable, Equatable, Hashable {
        /// The provider implements JSON APIs
        case json

        /// The provider implements XML APIs
        case xml
    }

    /// `PolisAPILevel` defines the three levels of API support
    ///
    /// POLIS is a complex standard. Its full implementation requires significant efforts, and not all organisations are
    /// able to invest or capable of implementing the full set of APIs. In order to simplify the implementation of POLIS
    /// Providers used by amateur clubs or in education, the standard defines three API levels. This simplest one is
    /// nothing more than a website with static resources.
    public enum APILevel: String, Codable, Equatable, Hashable {

        /// The service provider hosts only static data
        case staticData        = "static_data"

        /// If the status of observing sites is updated manually (e.g. by the admin) or automatically (by using POLIS-defined
        /// APIs), the service provider dynamically propagates the status information.
        case dynamicStatus     = "dynamic_status"

        /// The service provider can dynamically schedule observations (for sites that implement this functionality) and
        /// manage complex observation scheduling.
        case dynamicScheduling = "dynamic_scheduling"
    }

    /// Checks if the Device Type is supported by the given Implementation Info
    public static func isValid(deviceType: PolisDevice.DeviceType, for implementationInfo: PolisImplementationInfo) -> Bool {
        guard let possibleDevices = PolisImplementationInfo.devicesSupportedByVersion[implementationInfo.version] else  { return false }

        return possibleDevices.contains(deviceType)
    }

    /// Checks if device hierarchy is supported  by the given Implementation Info
    public static func canDevice(ofType: PolisDevice.DeviceType, beSubDeviceOfType: PolisDevice.DeviceType, for implementationInfo: PolisImplementationInfo) -> Bool {
        guard let possibleVersionCombinations = PolisImplementationInfo.subDevicesSupportedByVersion[implementationInfo.version] else { return false }
        guard let parentDevice                = possibleVersionCombinations[beSubDeviceOfType]                                   else { return false }

        return parentDevice.contains(ofType)
    }

    /// This is used to select the oldest supported implementation info in order to provide default data whenever needed
    ///
    ///  **Note:** The method assumes that the POLIS Service Provider implements at least one ImplementationInfo. Otherwise bad things will happen
    public static func oldestSupportedImplementationInfo() -> PolisImplementationInfo {
        var currentImplementationInfo: PolisImplementationInfo?

        for info in frameworkSupportedImplementation {
            if currentImplementationInfo != nil {
                if (currentImplementationInfo!.version > info.version) &&
                    (currentImplementationInfo!.apiSupport > info.apiSupport) &&
                    ((currentImplementationInfo!.dataFormat == .xml) && (info.dataFormat == .json)) {
                    currentImplementationInfo = info
                }
            }
            else { currentImplementationInfo = info }
        }

        return currentImplementationInfo!
    }

    public var dataFormat: DataFormat
    public var apiSupport: APILevel
    public var version: SemanticVersion

    public init(dataFormat: DataFormat, apiSupport: APILevel, version: SemanticVersion) {
        self.dataFormat = dataFormat
        self.apiSupport = apiSupport
        self.version    = version
    }

    //MARK: - Private definitions -
    private static var devicesSupportedByVersion = [SemanticVersion(with: "0.1-alpha.1") :
                                                        [PolisDevice.DeviceType.mirror,
                                                         PolisDevice.DeviceType.enclosure,
                                                        ]
    ]
    private static var subDevicesSupportedByVersion = [SemanticVersion(with: "0.1-alpha.1") : [PolisDevice.DeviceType.mirror : [PolisDevice.DeviceType.mirror],]]
}

/// A list of supported implementations for this concrete framework.
///
/// Until we have a stable version there should be only one supported version. After version 1.0 of the standard is
/// released, we should start supporting past versions.
public var frameworkSupportedImplementation: [PolisImplementationInfo] =
[
    PolisImplementationInfo(dataFormat: PolisImplementationInfo.DataFormat.json,
                            apiSupport: PolisImplementationInfo.APILevel.staticData,
                            version: SemanticVersion(with: "0.1-alpha.1")!
                           ),
]


//MARK: - Type extensions -
extension PolisImplementationInfo.APILevel: Comparable {
    public static func < (left: PolisImplementationInfo.APILevel, right: PolisImplementationInfo.APILevel) -> Bool {
        if      (left == .staticData)    && (left != right)               { return true }
        else if (left == .dynamicStatus) && (right == .dynamicScheduling) { return true }

        return false
    }
}

// This extension is needed for supporting a well formatted JSON API
public extension PolisImplementationInfo {
    enum CodingKeys: String, CodingKey {
        case dataFormat = "data_format"
        case apiSupport = "api_support"
        case version
    }
}

// This makes `PolisSupportedImplementation` Equatable
extension PolisImplementationInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataFormat)
        hasher.combine(apiSupport)
        hasher.combine(version.description)
    }
}

