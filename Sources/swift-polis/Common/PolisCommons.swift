//
//  PolisCommons.swift
//  
//
//  Created by Georg Tuparev on 07/10/2021.
//

import Foundation
import SoftwareEtudes
/// This is the first and only domain that is guaranteed to be a valid POLIS service provider.
///
/// There might be (hopefully) many more service providers, but one can start the domain search always from the POLIS'
/// Big Bang.
public let bigBangPolisDomain = "https://polis.onserver"



//MARK: - Supported POLIS Data formats, e.g. JSON, XML, ... -

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

/// An array of supported by the framework data formats.
public let frameworkSupportedDataFormats   = [PolisDataFormat.json]

/// The preferred supported data format
public let frameworkPreferredDataFormat    = PolisDataFormat.json

/// File extension (e.g. json, xml, ...) of static data Based on the preferred supported format.
public let frameworkPreferredFileExtension = PolisDataFormat.json.rawValue


//MARK: - Supported POLIS Data formats versions -

/// Returns a hardcoded list of supported by the framework POLIS Data Format versions
///
/// The list should be a strict subset of the versions defined by the POLIS standard. To avoid dealing with legacy
/// implementations it is recommended to aggressively remove older versions, specially initial versions before the first
/// 1.0 stable version.
///
/// Currently supported by the framework versions:
///    `json`: "0.0.0-alpha.1"
public func frameworkSupportedDataFormatVersions() -> [PolisDataFormat : [SemanticVersion]] {
    var result = [PolisDataFormat : [SemanticVersion]]()
    let json   = SemanticVersion(with: "0.1-alpha.1")!

    result[PolisDataFormat.json] = [json]

    return result
}

public func frameworkSupportedVersions(forDataFormat format: PolisDataFormat) -> [SemanticVersion]? {
    let allVersions = frameworkSupportedDataFormatVersions()

    return allVersions[format]
}

