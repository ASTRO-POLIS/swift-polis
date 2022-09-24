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

public class PolisStaticResourceFinder {

    /// Template definition of well known paths and APIs
    ///
    /// All paths start with the root directory `polis` followed by the `version`. The only exceptions are the main POLIS
    /// Provider info file (/polis/polis.json) that defines all supported versions and POLIS Directory (/polis/polis_directory.json).
    ///
    /// If possible clients should consider  using the latest supported version.
    public struct PredefinedPaths {
        // Level 1 resource paths. These are folders or files.
        public static let baseServiceDirectory                  = "polis"            // e.g. /polis/
        public static let serviceProviderConfigurationFileName  = "polis"            // e.g. /polis/polis.json
        public static let serviceProviderSitesDirectoryFileName = "polis_directory"  // e.g. /polis/polis_directory.json
        public static let observingSitesDirectoryFileName       = "polis_sites"      // e.g. /polis/<version>/polis_sites.json
        public static let siteDirectory                         = "polis_sites"      // e.g. /polis/<version>/polis_sites/
        public static let polisResources                        = "polis_resources"  // e.g. /polis/<version>/polis_resources/ .. e.g. manufacturers
    }

    /// Possible (hopefully self-explanatory) errors while creating various Resource Finders
    public enum ResourceFinderError: Error {
        case basePathNotAccessible
        case noSupportedImplementation
    }

    public init(supportedImplementation: PolisImplementationInfo) throws {
        guard frameworkSupportedImplementation.contains(supportedImplementation) else { throw ResourceFinderError.noSupportedImplementation }

        self.dataFormaStringt = supportedImplementation.dataFormat.rawValue
        self.versionString    = supportedImplementation.version.description

        self.relativePats     = RelativePaths(versionString: versionString, fileExtension: dataFormaStringt)
    }

    func fileExtension() -> String { ".\(self.dataFormaStringt)" }    // e.g. ".json"

    let dataFormaStringt: String
    let versionString: String

    fileprivate let relativePats: RelativePaths
}

public class PolisFileResourceFinder: PolisStaticResourceFinder {

    public init(at path: URL, supportedImplementation: PolisImplementationInfo) throws {
        var enhancedPath = path

        if enhancedPath.scheme == nil { enhancedPath = URL(fileURLWithPath: path.path) }

        guard try enhancedPath.checkPromisedItemIsReachable()           else { throw PolisStaticResourceFinder.ResourceFinderError.basePathNotAccessible }
        guard enhancedPath.hasDirectoryPath                             else { throw ResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path) else { throw ResourceFinderError.basePathNotAccessible }

        rootPath = enhancedPath

        try super.init(supportedImplementation: supportedImplementation)
    }


    public func rootFolder() -> String      { normalisedPath(rootPath.path) }
    public func baseFolder() -> String      { normalisedPath("\(rootFolder())\(relativePats.basePath)") }
    public func sitesFolder() -> String     { normalisedPath("\(rootFolder())\(relativePats.sitesPath())") }
    public func resourcesFolder() -> String { normalisedPath("\(rootFolder())\(relativePats.resourcesPath())") }

    public func configurationFilePath() -> String           { "\(rootFolder())\(relativePats.configurationFilePath())" }
    public func sitesDirectoryFilePath() -> String          { "\(rootFolder())\(relativePats.providerSitesDirectoryFilePath())" }
    public func observingSitesDirectoryFilePath() -> String { "\(rootFolder())\(relativePats.polisObservingSitesDirectoryFilePath())" }

    public func observingSiteFilePath(siteID: String) -> String               { "\(sitesFolder())\(siteID)/\(siteID)\(fileExtension())" }
    public func resourcesPath(uniqueName: String) -> String                   { normalisedPath("\(resourcesFolder())\(uniqueName)") }
    public func observingDataFilePath(withID: UUID, siteID: String) -> String { "\(sitesFolder())\(siteID)/\(withID.uuidString)\(fileExtension())" }

    private let rootPath: URL
}


public class PolisRemoteResourceFinder: PolisStaticResourceFinder {

    public init(at domain: URL, supportedImplementation: PolisImplementationInfo) throws {
        self.domain = "\(domain.absoluteString)"

        try super.init(supportedImplementation: supportedImplementation)
    }

    public func polisDomain() -> String { domain }

    public func baseURL() -> String      { normalisedPath("\(polisDomain())\(relativePats.basePath)") }
    public func sitesURL() -> String     { normalisedPath("\(polisDomain())\(relativePats.sitesPath())") }
    public func resourcesURL() -> String { normalisedPath("\(polisDomain())\(relativePats.resourcesPath())") }

    public func configurationURL() -> String           { "\(polisDomain())\(relativePats.configurationFilePath())" }
    public func sitesDirectoryURL() -> String          { "\(polisDomain())\(relativePats.providerSitesDirectoryFilePath())" }
    public func observingSitesDirectoryURL() -> String { "\(polisDomain())\(relativePats.polisObservingSitesDirectoryFilePath())" }

    public func observingSiteURL(siteID: String) -> String               { "\(sitesURL())\(siteID)/\(siteID)\(fileExtension())" }
    public func resourcesURL(uniqueName: String) -> String               { "\(resourcesURL())\(uniqueName)/" }
    public func observingDataURL(withID: UUID, siteID: String) -> String { "\(sitesURL())\(siteID)/\(withID.uuidString)\(fileExtension())" }

    private let domain: String
}

fileprivate struct RelativePaths {
    var versionString: String
    var fileExtension: String

    // Folder paths
    let basePath = "\(PolisStaticResourceFinder.PredefinedPaths.baseServiceDirectory)/"

    func sitesPath() -> String     { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.siteDirectory)"}
    func resourcesPath() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.polisResources)" }

    // File paths
    func configurationFilePath() -> String                { "\(basePath)\(PolisStaticResourceFinder.PredefinedPaths.serviceProviderConfigurationFileName).\(fileExtension)" }
    func providerSitesDirectoryFilePath() -> String       { "\(basePath)\(PolisStaticResourceFinder.PredefinedPaths.serviceProviderSitesDirectoryFileName).\(fileExtension)" }
    func polisObservingSitesDirectoryFilePath() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.observingSitesDirectoryFileName).\(fileExtension)" }
}

