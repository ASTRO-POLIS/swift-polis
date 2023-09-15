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
        public static let baseServiceDirectory                  = "polis"                      // e.g. /polis/
        public static let serviceProviderConfigurationFileName  = "polis"                      // e.g. /polis/polis.json
        public static let serviceProviderDirectoryFileName      = "polis_directory"            // e.g. /polis/polis_directory.json
        public static let observingFacilitiesDirectory          = "polis_observing_facilities" // e.g. /polis/<version>/polis_observing_facilities/
        public static let observingFacilitiesDirectoryFileName  = "polis_observing_facilities" // e.g. /polis/<version>/polis_observing_facilities.json
        public static let polisResources                        = "polis_resources"            // e.g. /polis/<version>/polis_resources/ .. e.g. manufacturers
        public static let polisResourcesDirectoryFileName       = "polis_resources"            // e.g. /polis/<version>/polis_resources/polis_resources.json
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
        guard enhancedPath.isDirectoryPath()                            else { throw ResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path) else { throw ResourceFinderError.basePathNotAccessible }

        rootPath = enhancedPath

        try super.init(supportedImplementation: supportedImplementation)
    }


    public func rootFolder() -> String                { rootPath.path.normalisedPath() }
    public func baseFolder() -> String                { "\(rootFolder())\(relativePaths.basePath)".normalisedPath() }
    public func observingFacilitiesFolder() -> String { "\(rootFolder())\(relativePaths.observingFacilitiesPath())".normalisedPath() }
    public func resourcesFolder() -> String           { "\(rootFolder())\(relativePaths.resourcesPath())".normalisedPath() }

    public func configurationFile() -> String                { "\(rootFolder())\(relativePaths.configurationFile())" }
    public func polisProviderDirectoryFile() -> String       { "\(rootFolder())\(relativePaths.polisProviderDirectoryFile())" }
    public func observingFacilitiesDirectoryFile() -> String { "\(rootFolder())\(relativePaths.polisObservingFacilitiesDirectoryFile())" }
    public func resourcesDirectoryFile() -> String           { "\(rootFolder())\(relativePaths.polisResourcesDirectoryFile())" }

    public func observingFacilityFolder(observingFacilityID: String) -> String         { "\(observingFacilitiesFolder())\(observingFacilityID)".normalisedPath() }
    public func observingFacilityFile(observingFacilityID: String) -> String           { "\(observingFacilitiesFolder())\(observingFacilityID)/\(observingFacilityID)\(fileExtension())" }
    public func observingDataFile(withID: UUID, observingFacilityID: String) -> String { "\(observingFacilitiesFolder())\(observingFacilityID)/\(withID.uuidString)\(fileExtension())" }
    public func resourcesFolder(uniqueName: String) -> String                          { "\(resourcesFolder())\(uniqueName)".normalisedPath() }

    private let rootPath: URL
}


public class PolisRemoteResourceFinder: PolisStaticResourceFinder {

    public init(at domain: URL, supportedImplementation: PolisImplementation) throws {
        self.domain = "\(domain.absoluteString)"
        if !self.domain.hasSuffix("/") { self.domain.append("/") }

        try super.init(supportedImplementation: supportedImplementation)
    }

    public func polisDomain() -> String { domain }

    public func baseURL() -> String                { "\(polisDomain())\(relativePaths.basePath)".normalisedPath() }
    public func observingFacilitiesURL() -> String { "\(polisDomain())\(relativePaths.observingFacilitiesPath())".normalisedPath() }
    public func resourcesURL() -> String           { "\(polisDomain())\(relativePaths.resourcesPath())".normalisedPath() }

    public func configurationURL() -> String                { "\(polisDomain())\(relativePaths.configurationFile())" }
    public func polisProviderDirectoryURL() -> String       { "\(polisDomain())\(relativePaths.polisProviderDirectoryFile())" }
    public func observingFacilitiesDirectoryURL() -> String { "\(polisDomain())\(relativePaths.polisObservingFacilitiesDirectoryFile())" }

    public func observingFacilityURL(observingFacilityID: String) -> String           { "\(observingFacilitiesURL())\(observingFacilityID)/\(observingFacilityID)\(fileExtension())" }
    public func observingDataURL(withID: UUID, observingFacilityID: String) -> String { "\(observingFacilitiesURL())\(observingFacilityID)/\(withID.uuidString)\(fileExtension())" }

    private var domain: String
}

fileprivate struct RelativePaths {
    var versionString: String
    var fileExtension: String

    // Folder paths
    let basePath = "\(PolisStaticResourceFinder.PredefinedPaths.baseServiceDirectory)/"

    func observingFacilitiesPath() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.observingFacilitiesDirectory)"}
    func resourcesPath() -> String           { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.polisResources)" }

    // File paths
    func configurationFile() -> String                     { "\(basePath)\(PolisStaticResourceFinder.PredefinedPaths.serviceProviderConfigurationFileName).\(fileExtension)" }
    func polisProviderDirectoryFile() -> String            { "\(basePath)\(PolisStaticResourceFinder.PredefinedPaths.serviceProviderDirectoryFileName).\(fileExtension)" }
    func polisObservingFacilitiesDirectoryFile() -> String { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.observingFacilitiesDirectoryFileName).\(fileExtension)" }
    func polisResourcesDirectoryFile() -> String           { "\(basePath)\(versionString)/\(PolisStaticResourceFinder.PredefinedPaths.polisResourcesDirectoryFileName).\(fileExtension)" }
}

