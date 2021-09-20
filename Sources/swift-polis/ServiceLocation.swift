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

 - <domain>/polis/observing_sites_directory.json [required]
 - <domain>/polis/observing_sites_directory.xml  [optional]
 Directory (list) of known observing sites containing their IDs, last update dates, and optional short names. It is
 recommended that clients cache this list and access the full observing site only on demand.

 */

/// Definition of well known paths and APIs
public struct PolisPredefinedServicePaths {
    public static let defaultDomainName = "https://polis.observer/"

    // Level 1 resource paths
    public static let rootServiceDirectory                  = "polis"                      // e.g. /polis/
    public static let serviceProviderConfigurationFileName  = "polis"                      // e.g. /polis/polis.json
    public static let serviceProviderSitesDirectoryFileName = "polis_directory"            // e.g. /polis/polis_directory.json
    public static let observingSitesDirectoryFileName       = "observing_sites_directory"  // e.g. /polis/observing_sites_directory.json
    public static let siteDirectory                         = "polis_sites"                // e.g. /polis/polis_sites/
}

/// The following few functions constructs paths to various POLIS files. It is preferred to use them instead of constructing
/// path URL manually, because the file organisation of the POLIS provider might change in the future
///
/// - `rootPolisFolder()`             - returns the root folder + `rootServiceDirectory`
/// - `polisSiteDirectory()`          - returns the folder  containing all observing site data
/// - `rootPolisFile()`               - returns the path of the root configuration file
/// - `rootPolisDirectoryFile()`      - returns the path of the directory of known POLIS providers
/// - `observingSitesDirectoryFile()` - returns the path to a file containing a list of all known observing site IDs
/// - `observingSiteFile()`           - returns the path to a file containing observing site data


///
/// Defines the root folder containing all static files (JSON and XML) of a POLIS provider.
/// This function does not validate the correctness or path or if the folder is accessible for reading and writing.
/// - Parameter rootPath: The path leading to the root polis folder.
/// - Returns: Returns the root POLIS folder.
public func rootPolisFolder(rootPath: URL) -> URL {
    var result = normalisedPath(rootPath)

    result.appendPathComponent("\(PolisPredefinedServicePaths.rootServiceDirectory)/", isDirectory: true)

    return result
}

public func polisSitesFolder(rootPath: URL) -> URL {
    var result = rootPolisFolder(rootPath: rootPath)

    result.appendPathComponent("\(PolisPredefinedServicePaths.siteDirectory)/", isDirectory: true)

    return result
}


public func rootPolisFile(rootPath: URL, format: PolisDataFormat = .json) -> URL {
    var result = rootPolisFolder(rootPath: rootPath)

    result.appendPathComponent( "\(PolisPredefinedServicePaths.serviceProviderConfigurationFileName).\(format.rawValue)", isDirectory: false)

    return result
}

public func rootPolisDirectoryFile(rootPath: URL, format: PolisDataFormat = .json) -> URL {
    var result = rootPolisFolder(rootPath: rootPath)

    result.appendPathComponent( "\(PolisPredefinedServicePaths.serviceProviderSitesDirectoryFileName).\(format.rawValue)", isDirectory: false)

    return result
}

public func observingSitesDirectoryFile(rootPath: URL, format: PolisDataFormat = .json) -> URL {
    var result = rootPolisFolder(rootPath: rootPath)

    result.appendPathComponent("\(PolisPredefinedServicePaths.observingSitesDirectoryFileName).\(format.rawValue)", isDirectory: false)

    return result
}

public func observingSiteFile(rootPath: URL, siteID: String, format: PolisDataFormat = .json) -> URL {
    var result = polisSitesFolder(rootPath: rootPath)

    result.appendPathComponent( "\(siteID).\(format.rawValue)", isDirectory: false)

    return result
}

/// This is for internal use only! Without this the URL returned by the utility functions for some strange reason has no
/// URL schema!
fileprivate func normalisedPath(_ path: URL) -> URL {
    let strPath = path.path

    if strPath.hasSuffix("/") { return path }
    else                      { return URL(fileURLWithPath: "\(strPath)/") }
}
