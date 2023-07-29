//===----------------------------------------------------------------------===//
//  PolisStaticResourceFinder.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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
        public static let siteDirectory                         = "polis_sites"      // e.g. /polis/<version>/polis_sites/
        public static let sitesDirectoryFileName                = "polis_sites"      // e.g. /polis/<version>/polis_sites.json
        public static let polisResources                        = "polis_resources"  // e.g. /polis/<version>/polis_resources/ .. e.g. manufacturers
        public static let polisResourcesDirectoryFileName       = "polis_resources"  // e.g. /polis/<version>/polis_resources/polis_resources.json
    }

    /// Possible (hopefully self-explanatory) errors while creating various Resource Finders
    public enum ResourceFinderError: Error {
        case basePathNotAccessible
        case noSupportedImplementation
    }

    public init(supportedImplementation: PolisImplementation) throws {
        guard PolisConstants.frameworkSupportedImplementation.contains(supportedImplementation) else { throw ResourceFinderError.noSupportedImplementation }

        self.dataFormatString = supportedImplementation.dataFormat.rawValue
        self.versionString    = supportedImplementation.version.description
        self.relativePaths    = RelativePaths(versionString: versionString, fileExtension: dataFormatString)
    }

    func fileExtension() -> String { ".\(self.dataFormatString)" }    // e.g. ".json"

    let dataFormatString: String
    let versionString: String

    fileprivate let relativePaths: RelativePaths
}

public class PolisFileResourceFinder: PolisStaticResourceFinder {

    public init(at path: URL, supportedImplementation: PolisImplementation) throws {
        var enhancedPath = path

        if enhancedPath.scheme == nil { enhancedPath = URL(fileURLWithPath: path.path) }

        guard try enhancedPath.checkPromisedItemIsReachable()           else { throw ResourceFinderError.basePathNotAccessible }
        guard enhancedPath.hasDirectoryPath                             else { throw ResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path) else { throw ResourceFinderError.basePathNotAccessible }

        rootPath = enhancedPath

        try super.init(supportedImplementation: supportedImplementation)
    }


    public func rootFolder() -> String      { rootPath.path.normalisedPath() }
    public func baseFolder() -> String      { "\(rootFolder())\(relativePaths.basePath)".normalisedPath() }
    public func sitesFolder() -> String     { "\(rootFolder())\(relativePaths.sitesPath())".normalisedPath() }
    public func resourcesFolder() -> String { "\(rootFolder())\(relativePaths.resourcesPath())".normalisedPath() }

    public func configurationFilePath() -> String           { "\(rootFolder())\(relativePaths.configurationFilePath())" }
    public func sitesDirectoryFilePath() -> String          { "\(rootFolder())\(relativePaths.providerSitesDirectoryFilePath())" }
    public func observingSitesDirectoryFilePath() -> String { "\(rootFolder())\(relativePaths.polisObservingSitesDirectoryFilePath())" }
    public func resourcesDirectoryFilePath() -> String      { "\(rootFolder())\(relativePaths.polisResourcesDirectoryFilePath())" }

    public func observingSiteFilePath(siteID: String) -> String               { "\(sitesFolder())\(siteID)/\(siteID)\(fileExtension())" }
    public func resourcesPath(uniqueName: String) -> String                   { "\(resourcesFolder())\(uniqueName)".normalisedPath() }
    public func observingDataFilePath(withID: UUID, siteID: String) -> String { "\(sitesFolder())\(siteID)/\(withID.uuidString)\(fileExtension())" }

    private let rootPath: URL
}


public class PolisRemoteResourceFinder: PolisStaticResourceFinder {

    public init(at domain: URL, supportedImplementation: PolisImplementation) throws {
        self.domain = "\(domain.absoluteString)"
        if !self.domain.hasSuffix("/") { self.domain.append("/") }

        try super.init(supportedImplementation: supportedImplementation)
    }

    public func polisDomain() -> String { domain }

    public func baseURL() -> String      { "\(polisDomain())\(relativePaths.basePath)".normalisedPath() }
    public func sitesURL() -> String     { "\(polisDomain())\(relativePaths.sitesPath())".normalisedPath() }
    public func resourcesURL() -> String { "\(polisDomain())\(relativePaths.resourcesPath())".normalisedPath() }

    public func configurationURL() -> String           { "\(polisDomain())\(relativePaths.configurationFilePath())" }
    public func sitesDirectoryURL() -> String          { "\(polisDomain())\(relativePaths.providerSitesDirectoryFilePath())" }
    public func observingSitesDirectoryURL() -> String { "\(polisDomain())\(relativePaths.polisObservingSitesDirectoryFilePath())" }
    public func resourcesDirectoryURL() -> String      { "\(polisDomain())\(relativePaths.polisResourcesDirectoryFilePath())" }

    public func observingSiteURL(siteID: String) -> String               { "\(sitesURL())\(siteID)/\(siteID)\(fileExtension())" }
    public func resourcesURL(uniqueName: String) -> String               { "\(resourcesURL())\(uniqueName)/" }
    public func observingDataURL(withID: UUID, siteID: String) -> String { "\(sitesURL())\(siteID)/\(withID.uuidString)\(fileExtension())" }

    private var domain: String
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
    func polisObservingSitesDirectoryFilePath() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.sitesDirectoryFileName).\(fileExtension)" }
    func polisResourcesDirectoryFilePath() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.polisResourcesDirectoryFileName).\(fileExtension)" }
}

