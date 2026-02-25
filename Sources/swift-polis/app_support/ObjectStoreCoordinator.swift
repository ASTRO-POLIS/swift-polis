//
//  ObjectStoreCoordinator.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation
import Logging
import SoftwareEtudesUtilities
import SoftwareEtudesLogging

public actor ObjectStoreCoordinator {

    //MARK: Static APIs

    @MainActor public static let shared = ObjectStoreCoordinator()

    @MainActor public static var isBigBangServiceProvider = false

    //MARK: Sub-types

    public enum ObjectStoreCoordinatorError: Error {
        case unaccessiblePath
        case unaccessibleRemoteHost
        case cannotWriteFileToLocalStore
        case objectStoreNotConfigured
        case cannotAccessOrCreateStandardPolisFolders
        case rootPathNotSet
        case cannotCreatePolisObjectFromStringExample
        case missingServiceProvider

        case unknownError
    }

    //MARK: Public APIs

    /// If a new (different) path is set, the ObjectStore will be reset or created
    public func setPathToPolisFolder(_ path: String) throws {
        if path == _pathToPolisFolder { return }

        if _fm.fileExists(atPath: path, isDirectory: &_isDir) && _isDir.boolValue {
            _pathToPolisFolder = path.normalisedFolderPath()
            resetObjectStore()
        }
        else { throw ObjectStoreCoordinatorError.unaccessiblePath }
    }


    /// If local Object Store is empty, this method will start creating the local store syncing it with the remote store.
    ///
    /// **Note:** The process of syncing could be slow. Appropriate Notifications will be posted when the syncing is complete.
    public func setRemoteProvider(host: String, pathToPolisFolder: String? = nil) throws {
        if host == _remoteHost { return }

        _remoteHost = host
        resetObjectStore()
        //TODO: Implement me!
    }

    public func logger() -> Logging.Logger { _logger }
    public func setLogFilePath( _ path: String) throws {
        //TODO: If current log file exists, flush and start a new one.
        _logFile = path
    }

    public func fileResourceFinder() -> PolisFileResourceFinder? { _fileResourceFinder }

    //MARK: - Private APIs
#if os(macOS)
    private var _logFile: String? = "/tmp/polis.log"
#else
    private var _logFile: String? = nil
#endif

    /// This is the only logger used in POLIS
    private var _logger: Logging.Logger

    private let _fm: FileManager = .default
    private var _isDir: ObjCBool = false

    private var _isConfigured    = false
    private var _pathToPolisFolder: String!
    private var _remoteHost: String?

    private var _fileResourceFinder: PolisFileResourceFinder!
    private var _remoteResourceFinder: PolisRemoteResourceFinder!

    private var _objectStoreDescription = ObjectStoreDescription(status: .notConfigured)

    private var _serviceProvider: ServiceProvider?
    private var _serviceProviderDirectory: ServiceProviderDirectory?

    @MainActor private init() {
        //FIXME: This will crash on iOS!
        let logFileURL = URL(fileURLWithPath: _logFile!)

        //TODO: Log File might be undefined ($$$AK, please fix)
        // Initialising the Log to channel to console and file
        PolisLogger.setup(subsystem: "test.polis.observer",
                          level: Logging.Logger.Level.trace,
                          logFileURL: logFileURL,
                          includeConsole: true)
        self._logger = PolisLogger.logger()
        self._logger.info("ObjectStoreCoordinator initialised")
    }
}


//
// =====================================================================================================================
//


//MARK: - Global Object Store Functionality -
extension ObjectStoreCoordinator {
    @discardableResult public func objectStoreStatus() throws-> ObjectStoreDescription {
        if _isConfigured { return objectStoreDescription() }

        _objectStoreDescription.setRootPath(_pathToPolisFolder)
        _objectStoreDescription.setStatus(.notConfigured)

        // Check if the root pat is a valid URL
        guard let pathURL = URL(string: _pathToPolisFolder) else {
            _objectStoreDescription.setRootPathAccessibilityStatus(.unaccessible)
            _logger.error("\(String(describing: _pathToPolisFolder)) is not a valid URL")
            throw ObjectStoreCoordinatorError.unaccessiblePath
        }

        // Configure PolisFileResourceFinder
        _fileResourceFinder = try PolisFileResourceFinder(at: pathURL, supportedImplementation: PolisConstants().latestPolisFrameworkSupportedImplementation())
        _objectStoreDescription.setRootPathAccessibilityStatus(.accessible)
        _objectStoreDescription.setPolisFileResourceFinderStatus(.set)
        _objectStoreDescription.setStatus(.rootPathSetAndValid)
        _objectStoreDescription.setPolisFoldersAccessibilityStatus(.unaccessible)
        _objectStoreDescription.setPolisFilesAccessibilityStatus(.unaccessible)

        // Check if all essential paths exist
        if checkPolisDirectoryPathsExistence(paths: polisDirectoryPaths()) {
            _objectStoreDescription.setStatus(.folderHierarchyCreated)
            _objectStoreDescription.setPolisFoldersAccessibilityStatus(.accessible)
        }
        else { return objectStoreDescription() }

        // Check if all essential files exist
        if checkPolisFilesExistence(paths: essentialPolisFiles()) {
            _objectStoreDescription.setPolisFilesAccessibilityStatus(.accessible)
            _isConfigured = true //TODO: When finished, should be true
        }

        return objectStoreDescription()
    }

    /// Creates local POLIS provider
    ///
    /// The local data will be stored at the path set by `setRemoteProvider(host, pathToPolisFolder:)`. If data at the path already exist, and
    /// `moveExistingStore` is `true`, the existing folder will be moved to `/tmp` folder. Otherwise the existing store will be removed unconditionally.
    public func createLocalStore(moveExistingStore: Bool = false) async throws {
        try objectStoreStatus()
        var storeStatus = _objectStoreDescription.status

        // Remove or backup existing data
        if storeStatus.rawValue >= ObjectStoreStatusType.folderHierarchyCreated.rawValue {
            if moveExistingStore { try moveLocalDataToTemporaryFolder() }
            else                 { try removeExistingLocalDataIfNeeded() }
            try objectStoreStatus()
            storeStatus = _objectStoreDescription.status
        }

        // Now we have a clean slate to start creating the local store

        // 1. Create the folder structure first
        if !checkPolisDirectoryPathsExistence(paths: polisDirectoryPaths()) {
            if tryToEnsureFoldersExistence(paths: polisDirectoryPaths()) {
                _objectStoreDescription.setPolisFoldersAccessibilityStatus(.accessible)
                _objectStoreDescription.setStatus(.folderHierarchyCreated)
            }
            else {
                _objectStoreDescription.setPolisFoldersAccessibilityStatus(.unaccessible)
                throw ObjectStoreCoordinatorError.cannotAccessOrCreateStandardPolisFolders
            }
        }

        //TODO: Create & Store the service provider configuration file (polis.json)
        try await createServiceProviderConfigurationFile()

        //TODO: Create & Store the polis directory file (polis_directory.json)
        try await createPolisDirectoryFile()

        //TODO: Create & Store the observing facilities directory file (polis_observing_facilities.json)
        try await createObservingFacilitiesDirectoryFile()

        //        try prepareObjectStoreForUse(createIfNeeded: true)
        //TODO: Implement me!
   }


    /// Describes the status of the local POLIS provider
    public func objectStoreDescription() -> ObjectStoreDescription { _objectStoreDescription }

    /// Performs complete reset to:
    /// - `ObjectStoreCoordinator`
    /// - `ObjectStoreDescription`
    /// - `ObjectStore`
    private func resetObjectStore() {
        _isConfigured             = false
        _fileResourceFinder       = nil
        _remoteResourceFinder     = nil
        _serviceProvider          = nil
        _serviceProviderDirectory = nil

        _objectStoreDescription   = ObjectStoreDescription()

        ObjectStore.shared.reset()
    }

//    private func prepareObjectStoreForUse(createIfNeeded: Bool = false) throws {
//        // Check if all essential files exist
//        if !checkPolisFilesExistence(paths: essentialPolisFiles()) {
//            //TODO: Continue digging here!
//
//            if createIfNeeded {
//                //TODO: 1. Create polis main file
//                //TODO: 2. Create polis directory file
//                //TODO: 3. Create polis facility directory file
//
//                return
//            }
//            else {
//                _objectStoreDescription.setPolisFilesAccessibilityStatus(.unaccessible)
//                return
//            }
//        }
//        _objectStoreDescription.setPolisFilesAccessibilityStatus(.accessible)
//    }

    private func createServiceProviderConfigurationFile() async throws {
        var  polisDirectoryEntry: PolisDirectory.ProviderDirectoryEntry

        do {
            if await ObjectStoreCoordinator.isBigBangServiceProvider { polisDirectoryEntry = try ServiceProviderDataSource.bigBangPolisDirectoryEntryExample() }
            else                                                     { polisDirectoryEntry = try ServiceProviderDataSource.defaultPolisDirectoryEntryExample() }
            polisDirectoryEntry.lastUpdateTime = Date.now
            _serviceProvider                   = ServiceProvider(polisDirectoryEntry)

            let data = try  PrettyJSONEncoder().encode(polisDirectoryEntry)
            let path = await ServiceProvider.pathToLocalPolisFile()

            if !_fm.createFile(atPath: path, contents: data)  {
                _logger.error("Cannot save POLIS Directory Entry file to: \(path)")
                throw ObjectStoreCoordinatorError.cannotWriteFileToLocalStore
            }
        }
        catch {
            _logger.error("Error: create POLIS object out of example string")
            throw ObjectStoreCoordinatorError.cannotCreatePolisObjectFromStringExample
        }

        //TODO: Send Notification!
    }

    private func createPolisDirectoryFile() async throws {
        guard let polisDirectoryEntry = _serviceProvider?.directoryEntry else { throw ObjectStoreCoordinatorError.missingServiceProvider }
        guard let polisDirectory = PolisDirectory(lastUpdateTime: Date.now, providerDirectoryEntries: [polisDirectoryEntry])
        else { throw ObjectStoreCoordinatorError.missingServiceProvider }

        do {
            let data = try  PrettyJSONEncoder().encode(polisDirectory)
            let path = await ServiceProviderDirectory.pathToLocalPolisFile()

            if !_fm.createFile(atPath: path, contents: data)  {
                _logger.error("Cannot save POLIS Directory file to: \(path)")
                throw ObjectStoreCoordinatorError.cannotWriteFileToLocalStore
            }
            _serviceProviderDirectory = ServiceProviderDirectory(polisDirectory)
        }
        catch {
            _logger.error("Error: Cannot create POLIS Directory out of existing POLIS Directory Entry")
            throw ObjectStoreCoordinatorError.unknownError
        }
        //TODO: Send Notification!
    }

    private func createObservingFacilitiesDirectoryFile() async throws {
        //TODO: Implement me!
    }
}

//MARK: - Managing Observing Facilities -
extension ObjectStoreCoordinator {

    public func addObservingFacility(_ facility: ObservingFacility) { ObjectStore.shared.addObservingFacility(facility) }
}

//MARK: - Polis Service Providing -
extension ObjectStoreCoordinator {

    private func moveLocalDataToTemporaryFolder() throws {
        //TODO: Implement me!
    }

    /// Removes existing local POLIS data without asking questions
    private func removeExistingLocalDataIfNeeded() throws {
        let pathToExamine = "\(_pathToPolisFolder!)polis/"

        if _fm.fileExists(atPath: pathToExamine) { try _fm.removeItem(atPath: pathToExamine) }
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

    private func makeSureServiceProviderConfigurationFileExists() throws {
        //TODO: Implement me!
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
            _logger.error("Error: cannot access or create folder - \(error.localizedDescription)")
            return false
        }
    }

    private func ensurePolisFoldersExistence() -> Bool { tryToEnsureFoldersExistence(paths: polisDirectoryPaths()) }

}

