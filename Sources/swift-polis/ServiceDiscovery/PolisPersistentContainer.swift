//
//  PolisPersistentContainer.swift
//  
//
//  Created by Georg Tuparev on 09/07/2021.
//

import Foundation


@available(iOS 10, macOS 10.12, *)
public class PolisPersistentContainer {

    /// The path leading to the folder containing all POLIS static data
    public var rootPath: URL

    //MARK: - Access to raw data (read only)
    public var polisRootDirectoryEntry: PolisDirectoryEntry? {
        get { currentPolisDirectoryEntry }
    }

    public var polisProviderDirectory: PolisDirectory? {
        get { currentPolisDirectory }
    }

    public var observatorySites: ObservatorySiteDirectory? {
        get { currentObservatorySiteDirectory }
    }

    //MARK: - Public methods -
    public init?(rootPath: URL, createIfEmpty: Bool = false) {
        self.rootPath = rootPath

        let loadResult = tryToLoadRequiredData()
        
        switch loadResult {
            case .loaded: return
            case .noData:
                if createIfEmpty && tryToCreateRequiredData() { return }
                else                                          { return nil }
            case .cannotLoad: return nil
        }
    }
    
    public func saveChange() throws {
        //TODO: Implement me!
        fatalError("saveChange NOT IMPLEMENTED!")
    }

    //MARK: - Private attributes -
    // Managing the state
    private var hasChanges = false

    // Folders and Files to check
    private var requiredFolders: [URL]!
    private var requiredFiles: [URL]!

    // Raw data
    private var currentPolisDirectoryEntry: PolisDirectoryEntry?
    private var currentPolisDirectory: PolisDirectory?
    private var currentObservatorySiteDirectory: ObservatorySiteDirectory?


    //MARK: - Loading required data -
    private enum PolisDataLoadingResult {
        case loaded
        case noData
        case cannotLoad
    }

    // NOTE: assumes that only JSON is supported!
    private func tryToLoadRequiredData() -> PolisDataLoadingResult {
        let fm              = FileManager.default
        var isDir: ObjCBool = false

        // 1. Check if the root path exists
        if !fm.fileExists(atPath: rootPath.path, isDirectory: &isDir) || !isDir.boolValue {
            //TODO: Add proper logging!
            return .cannotLoad
        }
        else { createRequiredDataResourceLists() } // Create lists of required folders and files

        // 2. Check if POLIS specific folders exist
        if !requiredFoldersExist() { return .noData }

        // 3. Check if POLIS required files exist
        if !requiredFilesExist() { return .noData }

        // 4. Read files and parse data
        if let dirEntry = polisDirectoryEntry(), let dir = polisDirectory(), let siteDir = observatorySiteDirectory() {
            currentPolisDirectoryEntry      = dirEntry
            currentPolisDirectory           = dir
            currentObservatorySiteDirectory = siteDir
        } else {
            //TODO: Add proper logging!
            return .cannotLoad
        }

        return .loaded
    }

    private func createRequiredDataResourceLists() {
        requiredFolders = [URL]()
        requiredFiles   = [URL]()

        requiredFolders.append(rootPolisFolder(rootPath: rootPath))
        requiredFolders.append(polisSitesFolder(rootPath: rootPath))

        requiredFiles.append(rootPolisFile(rootPath: rootPath))
        requiredFiles.append(rootPolisDirectoryFile(rootPath: rootPath))
        requiredFiles.append(observingSitesDirectoryFile(rootPath: rootPath))
    }

    private func requiredFoldersExist() -> Bool {
        let fm              = FileManager.default
        var isDir: ObjCBool = false

        for folderURL in requiredFolders {
            if !fm.fileExists(atPath: folderURL.path, isDirectory: &isDir) || !isDir.boolValue { return false }
        }

        return true
    }

    private func requiredFilesExist() -> Bool {
        let fm              = FileManager.default
        var isDir: ObjCBool = false

        for fileURL in requiredFiles{
            if !fm.fileExists(atPath: fileURL.path, isDirectory: &isDir) || isDir.boolValue { return false }
        }

        return true
    }

    private func polisDirectoryEntry() -> PolisDirectoryEntry? {
        let fm        = FileManager.default
        let entryPath = rootPolisFile(rootPath: rootPath)

        if fm.fileExists(atPath: entryPath.path) {
            let jsonDecoder = PolisJSONDecoder()
            do {
                let encodedString = try String(contentsOf: entryPath, encoding: .utf8)
                let dirEntry      = try jsonDecoder.decode(PolisDirectoryEntry.self, from: encodedString.data(using: .utf8)!)

                return dirEntry
            }
            catch {
                //TODO: Add proper logging!
                print("Cannot decode JSON data for root entry: \(error)")
                return nil
            }
        }
        return nil
    }

    private func polisDirectory() -> PolisDirectory? {
        let fm            = FileManager.default
        let directoryPath = rootPolisDirectoryFile(rootPath: rootPath)

        if fm.fileExists(atPath: directoryPath.path) {
            let jsonDecoder = PolisJSONDecoder()
            do {
                let encodedString = try String(contentsOf: directoryPath, encoding: .utf8)
                let dir           = try jsonDecoder.decode(PolisDirectory.self, from: encodedString.data(using: .utf8)!)

                return dir
            }
            catch {
                //TODO: Add proper logging!
                print("Cannot decode JSON data for directory entry: \(error)")
                return nil
            }
        }
        return nil
    }

    private func observatorySiteDirectory() -> ObservatorySiteDirectory? {
        let fm              = FileManager.default
        let observatoryPath = observingSitesDirectoryFile(rootPath: rootPath)

        if fm.fileExists(atPath: observatoryPath.path) {
            let jsonDecoder = PolisJSONDecoder()
            do {
                let encodedString = try String(contentsOf: observatoryPath, encoding: .utf8)
                let observatories = try jsonDecoder.decode(ObservatorySiteDirectory.self, from: encodedString.data(using: .utf8)!)

                return observatories
            }
            catch {
                //TODO: Add proper logging!
                print("Cannot decode JSON data for observatory entry: \(error)")
                return nil
            }
        }
        return nil
    }

    //MARK: - Creating required data -
    private func tryToCreateRequiredData() -> Bool { createRequiredFolders() && createRequiredFiles() }

    private func createRequiredFolders() -> Bool {
        let fm              = FileManager.default
        var isDir: ObjCBool = false

        do {
            for folderURL in requiredFolders {
                if !fm.fileExists(atPath: folderURL.path, isDirectory: &isDir) || !isDir.boolValue {
                    try fm.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                }
            }
        }
        catch {
            //TODO: Add proper logging!
            return false
        }

        return true
    }

    private func createRequiredFiles() -> Bool {
        let fm              = FileManager.default
        let now             = Date()
        let rootEntry       = bigBangPolisRootEntry()
        let rootDirectory   = PolisDirectory(lastUpdate:now, entries: [rootEntry])
        let siteDirectory   = ObservatorySiteDirectory(lastUpdate: now, entries: [])
        let jsonEncoder     = PolisJSONEncoder()
        let rootData        = try? jsonEncoder.encode(rootEntry)
        let directoryData   = try? jsonEncoder.encode(rootDirectory)
        let observatoryData = try? jsonEncoder.encode(siteDirectory)

        guard let rootDirectoryEntryData = rootData, let polisDirectoryData = directoryData, let observingSiteDirectoryData = observatoryData
        else {
            //TODO: Add proper logging!
            print(">>>> Error: Cannot create or JSON-encode basic POLIS types!")
            return false
        }

        // Here we assume that all required folders are already created
        if !fm.createFile(atPath: rootPolisFile(rootPath: rootPath).path, contents: rootDirectoryEntryData, attributes: nil) {
            //TODO: Add proper logging!
            print(">>>> Error: cannot create file at: \(rootPolisFile(rootPath: rootPath).path)")
            return false
        }

        if !fm.createFile(atPath: rootPolisDirectoryFile(rootPath: rootPath).path, contents: polisDirectoryData, attributes: nil) {
            //TODO: Add proper logging!
            print(">>>> Error: cannot create file at: \(rootPolisDirectoryFile(rootPath: rootPath).path)")
            return false
        }

        if !fm.createFile(atPath: observingSitesDirectoryFile(rootPath: rootPath).path, contents: observingSiteDirectoryData, attributes: nil) {
            //TODO: Add proper logging!
            print(">>>> Error: cannot create file at: \(observingSitesDirectoryFile(rootPath: rootPath).path)")
            return false
        }

        return true
    }

    private func bigBangPolisRootEntry() -> PolisDirectoryEntry {
        let polisAdmin     = PolisAdminContact(name: "Big Bang Admin",
                                               email: "admin@bigbang.nu",
                                               mobilePhone: nil,
                                               notes: "This is the Big Bang Administrator's account. Please email your questions and suggestion to this account.")!
        let rootAttributes = PolisItemAttributes(status: PolisLifecycleStatus.active,
                                                 lastUpdate: Date(),
                                                 name: "Big Bang Observer",
                                                 shortDescription: "This is the Big Bang provider")
        let rootEntry      = PolisDirectoryEntry(attributes: rootAttributes,
                                                 url: "https://bigbang.nu",
                                                 providerDescription: "This is the Big Bang provider",
                                                 supportedProtocolLevels: [1],
                                                 supportedAPIVersions: ["0.1.0"],
                                                 supportedFormats: [.json],
                                                 providerType: PolisProviderType.public,
                                                 contact: polisAdmin)
        return rootEntry
    }
}
