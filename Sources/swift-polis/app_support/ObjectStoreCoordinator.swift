//
//  ObjectStoreCoordinator.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation
import Logging
import SoftwareEtudesLogging

public actor ObjectStoreCoordinator {
    @MainActor public static let shared = ObjectStoreCoordinator()

    @MainActor public static var logFile = "/tmp/polis.log"

    public enum ObjectStoreCoordinatorError: Error {
        case unaccessiblePath
        case unaccessibleRemoteHost
        case objectStoreNotConfigured
        case cannotAccessOrCreateStandardPolisFolders
    }

    @MainActor public static func setLogFile(_ path: String) { logFile = path }

    /// This is the only logger used in POLIS
    public let logger: Logging.Logger

    /// If a new (different) path is set, the ObjectStore will be reset or created
    public func setPathToPolisFolder(_ path: String) throws {
        if path == _pathToPolisFolder { return }

        if _fm.fileExists(atPath: path, isDirectory: &_isDir) && _isDir.boolValue {
            _pathToPolisFolder = path
            resetObjectStoreIfNeeded()
            try prepareObjectStoreForUse()
        }
        else { throw ObjectStoreCoordinatorError.unaccessiblePath }
    }

    /// If local Object Store is empty, this method will start creating the local store syncing it with the remote store.
    ///
    /// **Note:** The process of syncing could be slow. Appropriate Notifications will be posted when the syncing is complete.
    public func setRemoteProvider(host: String, pathToPolisFolder: String? = nil) throws {

        //TODO: Implement me!
    }

    /// Creates local POLIS provider
    ///
    /// The local data will be stored at the path set by `setRemoteProvider(host, pathToPolisFolder:)`. If data at the path already exist, and
    /// `moveExistingStore` is `true`, the existing folder will be moved to `/tmp` folder. Otherwise error will be thrown. If there is an existing `ObjectStore`,
    /// the store will be given a chance to sync all unsaved data before being reset.
    public func createLocalStore(moveExistingStore: Bool? = false) throws {
        if (moveExistingStore != nil) && (moveExistingStore!) { try moveLocalDataToTemporaryFolder() }
        try createLocalInfrastructure()
        //TODO: Implement me!
    }

    //MARK: - Private APIs
    private let _fm: FileManager = .default
    private var _isDir: ObjCBool = false

    private var _isConfigured    = false
    private var _pathToPolisFolder: String!

    private var _fileResourceFinder: PolisFileResourceFinder!
    private var _remoteResourceFinder: PolisRemoteResourceFinder!

    private var _objectStoreDescription = ObjectStoreDescription(status: .unknown)

    @MainActor private init() {
        let logFileURL = URL(fileURLWithPath: ObjectStoreCoordinator.logFile)

        PolisLogger.setup(subsystem: "test.polis.observer",
                          level: Logging.Logger.Level.trace,
                          logFileURL: logFileURL,
                          includeConsole: true)

        self.logger = PolisLogger.logger()


        self.logger.info("ObjectStoreCoordinator initialised")
    }

    private func resetObjectStoreIfNeeded() {
        _isConfigured       = false
        _fileResourceFinder = nil
        //TODO: Implement me!
    }

    private func prepareObjectStoreForUse() throws {
        if _isConfigured { return }

        _objectStoreDescription.setRootPath(_pathToPolisFolder)

        guard let patURL = URL(string: _pathToPolisFolder) else {
            _objectStoreDescription.setRootPathAccessibilityStatus(.unaccessible)
            logger.error("\(String(describing: _pathToPolisFolder)) is not a valid URL")
            throw ObjectStoreCoordinatorError.unaccessiblePath
        }

        _fileResourceFinder = try PolisFileResourceFinder(at: patURL, supportedImplementation: PolisConstants().latestPolisFrameworkSupportedImplementation())

        _objectStoreDescription.setRootPathAccessibilityStatus(.accessible)

        _isConfigured       = true
        //TODO: Implement me!
    }
}

//MARK: - Configuration related APIs -
extension ObjectStoreCoordinator {
    private func tryToConfigureLocalObjectStore() {
        //TODO: Implement me!
    }

    private func initialiseObjectStoreDescription() {
        _objectStoreDescription.setStatus(.unknown)
        _objectStoreDescription.setRootPathAccessibilityStatus(.unset)
        //TODO: Implement me!
    }
}

//MARK: - Global Object Store Functionality -
extension ObjectStoreCoordinator {
    /// Describes the status of the local POLIS provider
    public func objectStoreDescription() async -> ObjectStoreDescription {
        if _objectStoreDescription.status != .configuredAndSynced { tryToConfigureLocalObjectStore() }

        //TODO: Implement me!
       return _objectStoreDescription
    }
}

//MARK: - Managing Observing Facilities -
extension ObjectStoreCoordinator {

    public func addObservingFacility(_ facility: ObservingFacility) { ObjectStore.shared.addObservingFacility(facility) }
}

//MARK: - Polis Service Providing -
extension ObjectStoreCoordinator {
    private func createLocalInfrastructure() throws {
        //TODO: Add proper Logs before throwing exceptions!
        
        // Assumes `_pathToPolisFolder` does not contain `polis` subfolder!
        guard let pathURL = URL(string: _pathToPolisFolder) else { throw ObjectStoreCoordinatorError.unaccessiblePath }
        _fileResourceFinder = try PolisFileResourceFinder(at: pathURL, supportedImplementation: PolisConstants().latestPolisFrameworkSupportedImplementation())

        // 1. Create POLIS Folders
        if !ensurePolisFoldersExistence() { throw ObjectStoreCoordinatorError.cannotAccessOrCreateStandardPolisFolders }
        //TODO: Implement me!
    }

    private func moveLocalDataToTemporaryFolder() throws {
        //TODO: Implement me!

    }

    /// This method returns all currently possible POLIS directories. Use it whenever the list is needed.
    private func polisDirectoryPaths() -> [String] {
        [
            _fileResourceFinder.baseFolder(),                        // ../polis/
            _fileResourceFinder.observingFacilitiesFolder(),         // ../polis/<version>/polis_observing_facilities/
            _fileResourceFinder.resourcesFolder(),                   // ../polis/<version>/polis_resources/
            _fileResourceFinder.ownersFolder(),                      // ../polis/<version>/polis_owners/
            _fileResourceFinder.manufacturersFolder(),               // ../polis/<version>/polis_manufacturers/
        ]
    }

    /// This method returns all currently possible POLIS essential files required by the standard. Use it whenever the list is needed.
    private func essentialPolisFiles() -> [String] {
        [
            _fileResourceFinder.configurationFile(),                 // ../polis/polis.json
            _fileResourceFinder.polisProviderDirectoryFile(),        // ../polis/polis_directory.json
            _fileResourceFinder.observingFacilitiesDirectoryFile(),  // ../polis/<version>/polis_observing_facilities.json
        ]
    }

    private func checkPolisDirectoryPathsExistence(paths: [String]) -> Bool {
        for path in paths {
            if !(_fm.fileExists(atPath: path, isDirectory: &_isDir) && (_isDir.boolValue)) {
                return false
            }
        }

        return true
    }

    private func checkPolisFilesExistence(paths: [String]) -> Bool {
        for path in paths {
            if !_fm.isReadableFile(atPath: path) { return false }
        }

        return true
    }


    //TODO: Move these methods to SoftwareEtudes
    func tryToEnsureFoldersExistence(paths: [String]) -> Bool {
        do {
            for path in paths {
                if !(_fm.fileExists(atPath: path, isDirectory: &_isDir) && (_isDir.boolValue)) {
                    try _fm.createDirectory(atPath: path, withIntermediateDirectories: true)
                }
            }
            return true
        }
        catch {
            logger.error("Error: cannot access or create folder - \(error.localizedDescription)")
            return false
        }
    }

    private func ensurePolisFoldersExistence() -> Bool { tryToEnsureFoldersExistence(paths: polisDirectoryPaths()) }

}

