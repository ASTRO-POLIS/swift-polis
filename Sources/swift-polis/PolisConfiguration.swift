//
//  PolisConfiguration.swift
//  
//
//  Created by Georg Tuparev on 16/09/2021.
//

import Foundation
import SoftwareEtudes

public enum PolisSupportedAPIVersions {
    case json(versions: [SemanticVersion])
    case xml(versions: [SemanticVersion])
}

/// Returns a hardcoded list of supported by the framework POLIS APIs
///
/// The list should be a strict subset of the versions defined by the POLIS standard. To avoid dealing with legacy
/// implementations it is recommended to aggressively remove older versions, specially initial versions before the first
/// 1.0 stable version.
///
/// Currently supported by the framework versions:
///    `json`: "0.0.0-alpha.1"
///    `xml`:
public func frameworkSupportedAPIVersions() -> [PolisSupportedAPIVersions] {
    let json   = PolisSupportedAPIVersions.json(versions: [SemanticVersion(majorNumber: 0, minorNumber: 0, preReleaseVersion: "alpha.1")])
    let xml    = PolisSupportedAPIVersions.xml(versions: [SemanticVersion]())
    let result = [json, xml]

    return result
}

// This is needed to read the content of `polis_api.json` without assuming any correctness in the actual format
typealias PolisAPIVersions = [[String : [String]]]

