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

    public enum ObjectStoreCoordinatorError: Error {
        case unaccessiblePath
        case unaccessibleRemoteHost
        case objectStoreNotConfigured
        case cannotAccessOrCreateStandardPolisFolders
    }

    public let logger: Logging.Logger

    public func setPathToPolisFolder(_ path: String) throws {
        if _fm.fileExists(atPath: path, isDirectory: &_isDir) && _isDir.boolValue {
            _pathToPolisFolder = path
            resetObjectStoreIfNeeded()
        }
        else { throw ObjectStoreCoordinatorError.unaccessiblePath }
    }

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

    private init() {
        PolisLogger.setup(subsystem: "test.polis.observer", level: Logging.Logger.Level.info)
        self.logger = PolisLogger.logger()

        self.logger.info("ObjectStoreCoordinator initialised")
    }

    private func resetObjectStoreIfNeeded() {
        //TODO: Implement me!
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
