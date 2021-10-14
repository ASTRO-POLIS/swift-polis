//
//  PolisStaticResourceFinder.swift
//  
//
//  Created by Georg Tuparev on 13/10/2021.
//

import Foundation
import SoftwareEtudes

/// Definition of well known paths and APIs
public struct PolisPredefinedServicePaths {
    // Level 1 resource paths
    public static let baseServiceDirectory                  = "polis"                      // e.g. /polis/
    public static let serviceProviderConfigurationFileName  = "polis"                      // e.g. /polis/polis.json
    public static let serviceProviderSitesDirectoryFileName = "polis_directory"            // e.g. /polis/polis_directory.json
    public static let observingSitesDirectoryFileName       = "observing_sites_directory"  // e.g. /polis/observing_sites_directory.json
    public static let siteDirectory                         = "polis_sites"                // e.g. /polis/polis_sites/
}


@available(iOS 10, macOS 10.12, *)
public struct PolisStaticResourceFinder {

    public enum PolisStaticResourceFinderError: Error {
        case basePathNotAccessible
        case dataFormatNotSupported
        case versionNotSupported
    }

    public init(at path: URL, dataFormat: PolisDataFormat, version: SemanticVersion) throws {
        guard frameworkSupportedDataFormats.contains(dataFormat)                                   else { throw PolisStaticResourceFinderError.dataFormatNotSupported }
        guard ((frameworkSupportedVersions(forDataFormat:dataFormat)?.contains(version)) ?? false) else { throw PolisStaticResourceFinderError.versionNotSupported }
        guard try path.checkPromisedItemIsReachable()                                              else { throw PolisStaticResourceFinderError.basePathNotAccessible }
        guard path.hasDirectoryPath                                                                else { throw PolisStaticResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: path.path)                                    else { throw PolisStaticResourceFinderError.basePathNotAccessible }

        basePath          = path
        polisDataFormat   = dataFormat
        dataFormatVersion = version
    }

    //MARK: - All methods below return absolute paths to POLIS resources without validating if they exist or are reachable!

    public func rootPolisFolder() -> String { normalisedPath(basePath.path) }
    public func basePolisFolder() -> String { normalisedPath("\(rootPolisFolder())\(PolisPredefinedServicePaths.baseServiceDirectory)") }



    private let basePath: URL
    private let polisDataFormat: PolisDataFormat
    private let dataFormatVersion: SemanticVersion

    private func fileExtension() -> String { ".\(self.polisDataFormat.rawValue)" }    // e.g. ".json"
}

/// This is for internal use only! Without this the URL returned by the utility functions for some strange reason has no
/// URL schema!
fileprivate func normalisedPath(_ path: String) -> String {
    if path.hasSuffix("/") { return path }
    else                   { return "\(path)/" }
}
