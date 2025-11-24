//===----------------------------------------------------------------------===//
//  PolisStaticResourceFinder.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
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

public class PolisFileResourceFinder {

    public init(at path: URL, supportedImplementation: PolisImplementation) throws {
        var enhancedPath = path

        if enhancedPath.scheme == nil { enhancedPath = URL(fileURLWithPath: path.path) }

        guard try enhancedPath.checkPromisedItemIsReachable()           else { throw PolisResourceFinderError.basePathNotAccessible }
        guard enhancedPath.isDirectoryPath()                            else { throw PolisResourceFinderError.basePathNotAccessible }
        guard FileManager.default.fileExists(atPath: enhancedPath.path) else { throw PolisResourceFinderError.basePathNotAccessible }

        rootPath       = enhancedPath
        resourceFinder = try StaticResourceFinder(supportedImplementation: supportedImplementation)
        relativePaths  = resourceFinder.relativePaths
    }


    public func rootFolder() -> String                { rootPath.path.normalisedFolderPath() }
    public func baseFolder() -> String                { "\(rootFolder())\(relativePaths.basePath)".normalisedFolderPath() }
    public func observingFacilitiesFolder() -> String { "\(rootFolder())\(relativePaths.observingFacilitiesPath())".normalisedFolderPath() }
    public func resourcesFolder() -> String           { "\(rootFolder())\(relativePaths.resourcesPath())".normalisedFolderPath() }
    public func ownersFolder() -> String              { "\(rootFolder())\(relativePaths.ownersPath())".normalisedFolderPath() }
    public func manufacturersFolder() -> String       { "\(rootFolder())\(relativePaths.manufacturersPath())".normalisedFolderPath() }

    public func configurationFile() -> String                { "\(rootFolder())\(relativePaths.configurationFile())" }
    public func polisProviderDirectoryFile() -> String       { "\(rootFolder())\(relativePaths.polisProviderDirectoryFile())" }
    public func observingFacilitiesDirectoryFile() -> String { "\(rootFolder())\(relativePaths.polisObservingFacilitiesDirectoryFile())" }
    public func resourcesDirectoryFile() -> String           { "\(rootFolder())\(relativePaths.polisResourcesDirectoryFile())" }
    public func ownersDirectoryFile() -> String              { "\(rootFolder())\(relativePaths.polisOwnersDirectoryFile())" }
    public func manufacturersDirectoryFile() -> String       { "\(rootFolder())\(relativePaths.polisManufacturersDirectoryFile())" }

    public func observingFacilityFolder(observingFacilityID: UUID) -> String         { "\(observingFacilitiesFolder())\(observingFacilityID.uuidString)".normalisedFolderPath() }
    public func observingFacilityFile(observingFacilityID: UUID) -> String           { "\(observingFacilitiesFolder())\(observingFacilityID.uuidString)/\(observingFacilityID)\(fileExtension())" }
    public func observingDataFile(withID: UUID, observingFacilityID: UUID) -> String { "\(observingFacilitiesFolder())\(observingFacilityID.uuidString)/\(withID.uuidString)\(fileExtension())" }
    public func resourcesFolder(uniqueName: String) -> String                        { "\(resourcesFolder())\(uniqueName)".normalisedFolderPath() }
    public func ownerDataFile(ownerID: UUID) -> String                               { "\(ownersFolder())\(ownerID.uuidString)\(fileExtension())" }
    public func manufacturerDataFile(manufacturerID: UUID) -> String                 { "\(manufacturersFolder())\(manufacturerID.uuidString)\(fileExtension())" }

    private let rootPath: URL
    private let resourceFinder: StaticResourceFinder
    private let relativePaths: RelativePaths

    private func fileExtension() -> String { ".\(resourceFinder.dataFormatString)" }    // e.g. ".json"
}


public class PolisRemoteResourceFinder {

    public init(at domain: URL, supportedImplementation: PolisImplementation) throws {
        self.domain = "\(domain.absoluteString)"
        if !self.domain.hasSuffix("/") { self.domain.append("/") }

        resourceFinder = try StaticResourceFinder(supportedImplementation: supportedImplementation)
        relativePaths  = resourceFinder.relativePaths

    }

    public func polisDomain() -> String { domain }

    public func baseURL() -> String                { "\(polisDomain())\(relativePaths.basePath)".normalisedFolderPath() }
    public func observingFacilitiesURL() -> String { "\(polisDomain())\(relativePaths.observingFacilitiesPath())".normalisedFolderPath() }
    public func resourcesURL() -> String           { "\(polisDomain())\(relativePaths.resourcesPath())".normalisedFolderPath() }
    public func ownersURL() -> String              { "\(polisDomain())\(relativePaths.ownersPath())".normalisedFolderPath() }
    public func manufacturerURL() -> String        { "\(polisDomain())\(relativePaths.manufacturersPath())".normalisedFolderPath() }

    public func configurationURL() -> String                { "\(polisDomain())\(relativePaths.configurationFile())" }
    public func polisProviderDirectoryURL() -> String       { "\(polisDomain())\(relativePaths.polisProviderDirectoryFile())" }
    public func observingFacilitiesDirectoryURL() -> String { "\(polisDomain())\(relativePaths.polisObservingFacilitiesDirectoryFile())" }
    public func ownersDirectoryURL() -> String              { "\(polisDomain())\(relativePaths.polisOwnersDirectoryFile())" }
    public func manufacturersDirectoryURL() -> String       { "\(polisDomain())\(relativePaths.polisManufacturersDirectoryFile())" }

    public func observingFacilityURL(observingFacilityID: UUID) -> String           { "\(observingFacilitiesURL())\(observingFacilityID.uuidString)/\(observingFacilityID)\(fileExtension())" }
    public func observingDataURL(withID: UUID, observingFacilityID: UUID) -> String { "\(observingFacilitiesURL())\(observingFacilityID.uuidString)/\(withID.uuidString)\(fileExtension())" }
    public func ownerDataURL(ownerID: UUID) -> String                               { "\(ownersDirectoryURL())\(ownerID.uuidString)/\(fileExtension())" }
    public func manufacturerDataURL(manufacturerID: UUID) -> String                 { "\(manufacturerURL())\(manufacturerID.uuidString)/\(fileExtension())" }

    private var domain: String
    private let resourceFinder: StaticResourceFinder
    private let relativePaths: RelativePaths

    private func fileExtension() -> String { ".\(resourceFinder.dataFormatString)" }    // e.g. ".json"

}

/// Possible (hopefully self-explanatory) errors while creating various Resource Finders
public enum PolisResourceFinderError: Error {
    case basePathNotAccessible
    case noSupportedImplementation
}

/// Template definition of well known paths and APIs
///
/// All paths start with the root directory `polis` followed by the `version`. The only exceptions are the main POLIS
/// Provider info file (/polis/polis.json) that defines all supported versions and POLIS Directory (/polis/polis_directory.json).
///
/// If possible clients should consider  using the latest supported version.
fileprivate struct PredefinedPaths {
    // Level 1 resource paths. These are folders or files.
    static let baseServiceDirectory                 = "polis"                      // e.g. /polis/
    static let serviceProviderConfigurationFileName = "polis"                      // e.g. /polis/polis.json
    static let serviceProviderDirectoryFileName     = "polis_directory"            // e.g. /polis/polis_directory.json
    static let observingFacilitiesDirectory         = "polis_observing_facilities" // e.g. /polis/<version>/polis_observing_facilities/
    static let observingFacilitiesDirectoryFileName = "polis_observing_facilities" // e.g. /polis/<version>/polis_observing_facilities.json
    static let polisResources                       = "polis_resources"            // e.g. /polis/<version>/polis_resources/ .. e.g. manufacturers
    static let polisResourcesDirectoryFileName      = "polis_resources"            // e.g. /polis/<version>/polis_resources/polis_resources.json
    static let polisOwners                          = "polis_owners"               // e.g. /polis/<version>/polis_owners/ .. e.g. Caltech
    static let polisOwnersDirectoryFileName         = "polis_owners"               // e.g. /polis/<version>/polis_owners/polis_owners.json
    static let polisManufacturers                   = "polis_manufacturers"        // e.g. /polis/<version>/polis_manufacturers/ .. e.g. ASA
    static let polisManufacturersDirectoryFileName  = "polis_manufacturers"        // e.g. /polis/<version>/polis_manufacturers/polis_manufacturers.json
}

fileprivate struct StaticResourceFinder {

    public init(supportedImplementation: PolisImplementation) throws {
        guard polisFrameworkSupportedImplementation.contains(supportedImplementation) else { throw PolisResourceFinderError.noSupportedImplementation }

        self.dataFormatString = supportedImplementation.dataFormat.rawValue
        self.versionString    = supportedImplementation.version.description
        self.relativePaths    = RelativePaths(versionString: versionString, fileExtension: dataFormatString)
    }

    let dataFormatString: String
    let versionString: String
    let relativePaths: RelativePaths

    func fileExtension() -> String { ".\(self.dataFormatString)" }    // e.g. ".json"
}



fileprivate struct RelativePaths {
    var versionString: String
    var fileExtension: String

    // Folder paths
    let basePath = "\(PredefinedPaths.baseServiceDirectory)/"

    func observingFacilitiesPath() -> String { "\(basePath)\(versionString)/\(PredefinedPaths.observingFacilitiesDirectory)"}
    func resourcesPath() -> String           { "\(basePath)\(versionString)/\(PredefinedPaths.polisResources)" }
    func ownersPath() -> String              { "\(basePath)\(versionString)/\(PredefinedPaths.polisOwners)" }
    func manufacturersPath() -> String       { "\(basePath)\(versionString)/\(PredefinedPaths.polisManufacturers)" }

    // File paths
    func configurationFile() -> String                     { "\(basePath)\(PredefinedPaths.serviceProviderConfigurationFileName).\(fileExtension)" }
    func polisProviderDirectoryFile() -> String            { "\(basePath)\(PredefinedPaths.serviceProviderDirectoryFileName).\(fileExtension)" }
    func polisObservingFacilitiesDirectoryFile() -> String { "\(basePath)\(versionString)/\(PredefinedPaths.observingFacilitiesDirectoryFileName).\(fileExtension)" }
    func polisResourcesDirectoryFile() -> String           { "\(basePath)\(versionString)/\(PredefinedPaths.polisResourcesDirectoryFileName).\(fileExtension)" }
    func polisOwnersDirectoryFile() -> String              { "\(basePath)\(versionString)/\(PredefinedPaths.polisOwnersDirectoryFileName).\(fileExtension)" }
    func polisManufacturersDirectoryFile() -> String       { "\(basePath)\(versionString)/\(PredefinedPaths.polisManufacturersDirectoryFileName).\(fileExtension)" }
}

