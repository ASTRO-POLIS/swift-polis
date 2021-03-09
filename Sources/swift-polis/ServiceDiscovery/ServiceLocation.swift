//
//  ServiceLocation.swift
//  
//
//  Created by Georg Tuparev on 20/11/2020.
//

import Foundation

/*
Thoughts about predefined pats and API queries:

 - <domain> - Something like https://polis.observer (it is recommended to support HTTPS)

 **Protocol level 1:**
 - <domain>/polis/polis.json           [required]
 - <domain>/polis/polis.xml            [optional]
    Describes the domain, its ID, type, ownership, contact etc.

 - <domain>/polis/polis_directory.json [required]
 - <domain>/polis/polis_directory.xml  [optional]
    List of all known POLIS providers

 - <domain>/polis/sites_directory.json [required]
 - <domain>/polis/sites_directory.xml  [optional]
    Directory (list) of known observing sites containing their IDs, last update dates, and optional short names. It is
    recommended that clients cache this list and access the full observing site only on demand.

 */

/// Definition of well known paths and APIs
public struct PolisPredefinedServicePaths {
    public static let defaultDomainName = "https://polis.observer/"

    // Level 1 resource paths
    public static let rootServiceDirectory                 = "polis"
    public static let serviceProviderConfigurationFileName = "polis"
    public static let siteDirectoryFileName                = "sites_directory"
    public static let siteDirectory                        = "polis_sites"
}

/// The following few functions constructs paths to various POLIS files. It is preferred to use them instead of constructing
/// path URL manually, because the file organisation of the POLIS provider might change in the future
///
/// - `rootPolisFile()`          - returns the path of the root configuration file
/// - `rootPolisDirectoryFile()` - returns the path of the directory of known POLIS providers
/// - `observingSiteFile()`      - returns the path to a file containing observing site data
public func rootPolisFile(rootPath: URL, format: PolisDataFormat = .json) -> URL {
    var result = normalisedPath(rootPath)

    result.appendPathComponent(
        "\(PolisPredefinedServicePaths.rootServiceDirectory)/\(PolisPredefinedServicePaths.serviceProviderConfigurationFileName).\(format.rawValue)",
        isDirectory: false)

    return result
}

public func rootPolisDirectoryFile(rootPath: URL, format: PolisDataFormat = .json) -> URL {
    var result = normalisedPath(rootPath)

    result.appendPathComponent(
        "\(PolisPredefinedServicePaths.rootServiceDirectory)/\(PolisPredefinedServicePaths.siteDirectoryFileName).\(format.rawValue)",
        isDirectory: false)

    return result
}

public func observingSiteFile(rootPath: URL, siteID: String, format: PolisDataFormat = .json) -> URL {
    var result = normalisedPath(rootPath)

    result.appendPathComponent(
        "\(PolisPredefinedServicePaths.rootServiceDirectory)/\(PolisPredefinedServicePaths.siteDirectory)/\(siteID).\(format.rawValue)",
        isDirectory: false)

    return result
}

/// This is for internal use only!
fileprivate func normalisedPath(_ path: URL) -> URL {
    let strPath = path.path

    if strPath.hasSuffix("/") { return path }
    else                      { return URL(fileURLWithPath: "\(strPath)/") }
}


//MARK: - JSON encoding / decoding support -
/// Use these JSONDecoder and JSONEncoder subclasses to convert types to and from JSON

@available(iOS 10, macOS 10.12, *)
public class PolisJSONDecoder: JSONDecoder {

    let dateFormatter = ISO8601DateFormatter()

    public override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date       = self.dateFormatter.date(from: dateString)

            if let date = date { return date }
            else               { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date values must be ISO8601 formatted") }
        }
    }
}

@available(iOS 10, macOS 10.12, *)
public class PolisJSONEncoder: JSONEncoder {
    public override init() {
        super.init()

        dateEncodingStrategy = .iso8601
    }
}

