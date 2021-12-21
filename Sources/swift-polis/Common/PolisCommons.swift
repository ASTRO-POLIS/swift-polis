//
//  PolisCommons.swift
//  
//
//  Created by Georg Tuparev on 07/10/2021.
//

import Foundation
import SoftwareEtudes

//Just checking commit
/// This is the first and only domain that is guaranteed to be a valid POLIS service provider.
///
/// There might be (hopefully) many more service providers, but one can start the domain search always from the POLIS'
/// Big Bang.
public let bigBangPolisDomain = "https://polis.onserver"



//MARK: - Supported POLIS Data formats, e.g. JSON, XML, ..., level of API support and versions -

/// Defines various POLIS data formats
///
/// POLIS APIs are encoded either in XML or in JSON format. For reasons stated elsewhere in the documentation, XML APIs
/// are preferred for production-ready code. In contrast, JSON is often easier to use for new development (no need of
/// schema support) and is often easier to be used within a mobile or a web applications. Due to its fragility
/// JSON-based implementation should be avoided in stable production systems.
///
/// The type implements the `Equatable` and the `Codable` protocols
public enum PolisDataFormat: String, Codable, Equatable {
    /// The provider implements JSON APIs
    case json

    /// The provider implements XML APIs
    case xml
}

/// `PolisAPISupport` defines the three levels of API support
public enum PolisAPISupport: String, Codable, Equatable {

    /// The service provider hosts only static (file based) data
    case staticData        = "static_data"

    /// If the status of observing sites is updated manually (e.g. by the admin) or automatically (by using POLIS-defined
    /// APIs), the service provider dynamically propagates this information.
    case dynamicStatus     = "dynamic_status"

    /// The service provider is able dynamically to schedule observations (for sites that implement this functionality)
    /// and manage complex level 2 observing projects.
    case dynamicScheduling = "dynamic_scheduling"
}

//TODO: Needs documentation
public enum PolisRoughDirection: String, Codable {
    case north     = "N"
    case northEast = "N/E"
    case east      = "E"
    case southEast = "S/E"
    case south     = "S"
    case southWest = "S/W"
    case west      = "W"
    case northWest = "N/W"
}

//TODO: Needs documentation
public enum PolisDirection: Codable {
    case rough(direction: PolisRoughDirection)
    case exact(degree: Double)
}

//TODO: Needs documentation!
/// `PolisSupportedImplementation` combines supported data format, API level, and version in a single struct
public struct PolisSupportedImplementation: Codable, Equatable {
    let dataFormat: PolisDataFormat
    let apiSupport: PolisAPISupport
    let version: SemanticVersion
}

//TODO: Needs documentation!
public var frameworkSupportedImplementation: [PolisSupportedImplementation] =
[
    PolisSupportedImplementation(dataFormat: PolisDataFormat.json, apiSupport: PolisAPISupport.staticData, version: SemanticVersion(with: "0.1-alpha.1")!),
]


//MARK: - Type extensions -

public extension PolisSupportedImplementation {
    enum CodingKeys: String, CodingKey {
        case dataFormat = "data_format"
        case apiSupport = "api_support"
        case version
    }
}
