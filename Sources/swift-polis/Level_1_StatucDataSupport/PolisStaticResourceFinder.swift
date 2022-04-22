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
import SoftwareEtudesUtilities

//TODO: Needs documentation!
//TODO: Needs testing of all path methods

/// Definition of well known paths and APIs
public struct PolisPredefinedServicePaths {
    // Level 1 resource paths. These are folders or files.
    public static let baseServiceDirectory                  = "polis"                      // e.g. /polis/
    public static let serviceProviderConfigurationFileName  = "polis"                      // e.g. /polis/polis.json
    public static let serviceProviderSitesDirectoryFileName = "polis_directory"            // e.g. /polis/polis_directory.json
    public static let observingSitesDirectoryFileName       = "observing_sites_directory"  // e.g. /polis/observing_sites_directory.json
    public static let siteDirectory                         = "polis_sites"                // e.g. /polis/polis_sites/
}


public struct PolisStaticResourceFinder {

    public enum PolisStaticResourceFinderError: Error {
        case basePathNotAccessible
        case noSupportedImplementation
    }

    public init(at path: URL, supportedImplementation: PolisSupportedImplementation) throws {
        var enhancedPath = path

        if enhancedPath.scheme == nil {
            let tempPath = "file://\(path.path)"
            enhancedPath = URL(fileURLWithPath: tempPath)
        }

        guard frameworkSupportedImplementation.contains(supportedImplementation) else { throw PolisStaticResourceFinderError.noSupportedImplementation }
        guard try enhancedPath.checkPromisedItemIsReachable()                    else { throw PolisStaticResourceFinderError.basePathNotAccessible }
        guard enhancedPath.hasDirectoryPath                                      else { throw PolisStaticResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path)          else { throw PolisStaticResourceFinderError.basePathNotAccessible }

        basePath        = enhancedPath
        polisDataFormat = supportedImplementation.dataFormat
    }


    //MARK: - All methods below return absolute paths to POLIS resources without validating if they exist or are reachable!

    public func rootPolisFolder() -> String  { normalisedPath(basePath.path) }
    public func basePolisFolder() -> String  { normalisedPath("\(rootPolisFolder())\(PolisPredefinedServicePaths.baseServiceDirectory)") }
    public func sitesPolisFolder() -> String { normalisedPath("\(basePolisFolder())\(PolisPredefinedServicePaths.siteDirectory)") }

    public func polisConfigurationFilePath(format: PolisDataFormat = .json) -> String {
        "\(basePolisFolder())\(PolisPredefinedServicePaths.serviceProviderConfigurationFileName).\(format.rawValue)"
    }

    public func polisProviderSitesDirectoryFilePath(format: PolisDataFormat = .json) -> String {
        "\(basePolisFolder())\(PolisPredefinedServicePaths.serviceProviderSitesDirectoryFileName).\(format.rawValue)"
    }

    public func polisObservingSitesDirectoryFilePath(format: PolisDataFormat = .json) -> String {
        "\(basePolisFolder())\(PolisPredefinedServicePaths.observingSitesDirectoryFileName).\(format.rawValue)"
    }

    public func polisObservingSiteFilePath(siteID: String, format: PolisDataFormat = .json) -> String { "\(sitesPolisFolder())\(siteID).\(format.rawValue)" }

    //MARK: - Private API
    private let basePath: URL
    private let polisDataFormat: PolisDataFormat

    private func fileExtension() -> String { ".\(self.polisDataFormat.rawValue)" }    // e.g. ".json"
}

/// This is for internal use only! Without this the URL returned by the utility functions for some strange reason has no
/// URL schema!
fileprivate func normalisedPath(_ path: String) -> String {
    if path.hasSuffix("/") { return path }
    else                   { return "\(path)/" }
}
