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

/// Template definition of well known paths and APIs
///
/// All paths start with the root directory `polis` followed by the `version`. The only exception is the main POLIS
/// Provider info file (/polis/polis.json) that defines all supported versions. If possible clients should consider
/// using the latest supported version.
public struct PolisPredefinedServicePaths {
    // Level 1 resource paths. These are folders or files.
    public static let baseServiceDirectory                  = "polis"            // e.g. /polis/
    public static let serviceProviderConfigurationFileName  = "polis"            // e.g. /polis/polis.json
    public static let serviceProviderSitesDirectoryFileName = "polis_directory"  // e.g. /polis/polis_directory.json
    public static let observingSitesDirectoryFileName       = "polis_sites"      // e.g. /polis/<version>/polis_sites.json
    public static let siteDirectory                         = "polis_sites"      // e.g. /polis/<version>/polis_sites/
    public static let polisResources                        = "polis_resources"  // e.g. /polis/<version>/polis_resources/ .. e.g. manufacturers
}


/// `PolisStaticResourceFinder` structure provides a way to access POLIS static (file based) resources.
///
/// **Note:** There are no checks is POLIS folders and files exist. Only the root folder needs to exist.
public struct PolisStaticResourceFinder {

    /// Possible (hopefully self-explanatory) errors while creating `PolisStaticResourceFinder`
    public enum StaticResourceFinderError: Error {
        case basePathNotAccessible
        case noSupportedImplementation
    }

    public init(at path: URL, supportedImplementation: PolisImplementationInfo) throws {
        var enhancedPath = path

        if enhancedPath.scheme == nil { enhancedPath = URL(fileURLWithPath: path.path) }

        guard frameworkSupportedImplementation.contains(supportedImplementation) else { throw StaticResourceFinderError.noSupportedImplementation }
        guard try enhancedPath.checkPromisedItemIsReachable()                    else { throw StaticResourceFinderError.basePathNotAccessible }
        guard enhancedPath.hasDirectoryPath                                      else { throw StaticResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path)          else { throw StaticResourceFinderError.basePathNotAccessible }

        basePath        = enhancedPath
        polisDataFormat = supportedImplementation.dataFormat
        versionString   = supportedImplementation.version.description
    }


    //MARK: - All methods below return absolute paths to POLIS resources without validating if they exist or are reachable!

    public func rootPolisFolder() -> String      { normalisedPath(basePath.path) }
    public func basePolisFolder() -> String      { normalisedPath("\(rootPolisFolder())\(PolisPredefinedServicePaths.baseServiceDirectory)") }
    public func sitesPolisFolder() -> String     { normalisedPath("\(basePolisFolder())\(versionString)/\(PolisPredefinedServicePaths.siteDirectory)") }
    public func resourcesPolisFolder() -> String { normalisedPath("\(basePolisFolder())\(versionString)/\(PolisPredefinedServicePaths.polisResources)") }

    public func polisConfigurationFilePath(format: PolisImplementationInfo.DataFormat = .json) -> String {
        "\(basePolisFolder())\(PolisPredefinedServicePaths.serviceProviderConfigurationFileName).\(format.rawValue)"
    }

    public func polisProviderSitesDirectoryFilePath(format: PolisImplementationInfo.DataFormat = .json) -> String {
        "\(basePolisFolder())\(PolisPredefinedServicePaths.serviceProviderSitesDirectoryFileName).\(format.rawValue)"
    }

    public func polisObservingSitesDirectoryFilePath(format: PolisImplementationInfo.DataFormat = .json) -> String {
        "\(basePolisFolder())\(versionString)/\(PolisPredefinedServicePaths.observingSitesDirectoryFileName).\(format.rawValue)"
    }

    public func polisObservingSiteFilePath(siteID: String, format: PolisImplementationInfo.DataFormat = .json) -> String { "\(sitesPolisFolder())\(siteID)/\(siteID).\(format.rawValue)" }

    public func polisResourcesPath(uniqueName: String, format: PolisImplementationInfo.DataFormat = .json) -> String { "\(resourcesPolisFolder())\(uniqueName)/\(uniqueName).\(format.rawValue)" }

    public func polisObservingDataFilePath(withID: UUID, siteID: String, format: PolisImplementationInfo.DataFormat = .json) -> String {
        "\(sitesPolisFolder())\(siteID)/\(withID.uuidString).\(format.rawValue)"
    }

    //MARK: - Private API
    private let basePath: URL
    private let polisDataFormat: PolisImplementationInfo.DataFormat
    private let versionString: String

    private func fileExtension() -> String { ".\(self.polisDataFormat.rawValue)" }    // e.g. ".json"
}

