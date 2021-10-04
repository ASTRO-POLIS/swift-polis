//
//  PolisConfiguration.swift
//  
//
//  Created by Georg Tuparev on 16/09/2021.
//

import Foundation
import SoftwareEtudes

public typealias PolisSupportedAPIVersion = [String : [SemanticVersion]]

public let polisSupportedAPIs = ["json", "xml"]

/// Returns a hardcoded list of supported by the framework POLIS APIs
///
/// The list should be a strict subset of the versions defined by the POLIS standard. To avoid dealing with legacy
/// implementations it is recommended to aggressively remove older versions, specially initial versions before the first
/// 1.0 stable version.
///
/// Currently supported by the framework versions:
///    `json`: "0.0.0-alpha.1"
///    `xml`:
public func frameworkSupportedAPIVersions() -> [PolisSupportedAPIVersion] {
    var result = [PolisSupportedAPIVersion]()
    let json   = SemanticVersion(with: "0.1-alpha.1")!

    result.append(["json" : [json]])
    result.append(["xml"  : []])

    return result
}

public func supportedAPIVersions(from string: String) -> [PolisSupportedAPIVersion]? {
    let jsonDecoder = JSONDecoder()

    guard let versions = try? jsonDecoder.decode([PolisSupportedAPIVersion].self, from: string.data(using: .utf8)!) else { return nil }

    return versions
    //TODO: Test this method!
}

public func jsonString(from: [PolisSupportedAPIVersion]) -> String? {
    let jsonEncoder = JSONEncoder()

    guard let data = try? jsonEncoder.encode(from) else { return nil }

    return  String(data: data, encoding: .utf8)
    //TODO: Test this method!
}

public func validate(polisSupportedAPIVersions: [PolisSupportedAPIVersion]) -> Bool {
    //FIXME: Do we really need this function?
    for apiVersion in polisSupportedAPIVersions {
        for (api, versions) in apiVersion {
            if !polisSupportedAPIs.contains(api) { return false }
            for frameworkVersion in frameworkSupportedAPIVersions() {
                for (frameworkAPI, frameworkVersions) in frameworkVersion {
                    if (frameworkAPI == api) {
                        for fV in frameworkVersions {
                            if versions.contains(fV) { return true }
                        }
                    }
                }
            }
        }
    }
    //TODO: Test this method!

    return false
}
