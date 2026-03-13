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
        case fileIO

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

    // Notifications
    private let _nc = NotificationCenter.default
    @MainActor private var _didChangeToken: NotificationCenter.ObservationToken?

    private var _isConfigured    = false
    private var _pathToPolisFolder: String!
    private var _remoteHost: String?

    private var _fileResourceFinder: PolisFileResourceFinder!
    private var _remoteResourceFinder: PolisRemoteResourceFinder!

    private var _os = ObjectStore.shared
    private var _objectStoreDescription = ObjectStoreDescription(status: .notConfigured)

    private var _serviceProvider: ServiceProvider?
    private var _serviceProviderDirectory: ServiceProviderDirectory?
    private var _observingFacilityDirectory: ObservingFacilityDirectory?

    @MainActor private init() {
        let logFileURL = _logFile.map { URL(fileURLWithPath: $0) }

        // Initialising the Log to channel to console and file
        PolisLogger.setup(subsystem: "test.polis.observer",
                          level: Logging.Logger.Level.trace,
                          logFileURL: logFileURL,
                          includeConsole: true)
        self._logger = PolisLogger.logger()
        self._logger.info("ObjectStoreCoordinator initialised")

        // Observing various notifications
        startObservingRepObjectChangeNotifications()
    }
}


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

        // 2. Create required files
        try await createServiceProviderConfigurationFile()
        try await createPolisDirectoryFile()
        try await createObservingFacilitiesDirectoryFile()

        // 3. Set the status as fully configured
        _objectStoreDescription.status = .fullyConfigured

        //TODO: 4. Configure the ObjectStore!
        //TODO: 5. If there is a remote provider, start the initial syncing.
   }


    /// Describes the status of the local POLIS provider
    public func objectStoreDescription() -> ObjectStoreDescription { _objectStoreDescription }

    /// Performs complete reset to:
    /// - `ObjectStoreCoordinator`
    /// - `ObjectStoreDescription`
    /// - `ObjectStore`
    private func resetObjectStore() {
        _isConfigured               = false
        _fileResourceFinder         = nil
        _remoteResourceFinder       = nil
        _serviceProvider            = nil
        _serviceProviderDirectory   = nil
        _observingFacilityDirectory = nil

        _objectStoreDescription     = ObjectStoreDescription()

        _os.reset()
    }

    private func createServiceProviderConfigurationFile() async throws {
        var  polisDirectoryEntry: PolisDirectory.ProviderDirectoryEntry

        do {
            if await ObjectStoreCoordinator.isBigBangServiceProvider { polisDirectoryEntry = try ServiceProviderDataSource.bigBangPolisDirectoryEntryExample() }
            else                                                     { polisDirectoryEntry = try ServiceProviderDataSource.defaultPolisDirectoryEntryExample() }

            polisDirectoryEntry.lastUpdateTime = Date.now
            _serviceProvider                   = await ServiceProvider(polisDirectoryEntry)

            await _serviceProvider?.setDidChange()
            try await _serviceProvider?.saveToLocalProvider()
        }
        catch {
            _logger.error("Error: create POLIS object out of example string")
            throw ObjectStoreCoordinatorError.cannotCreatePolisObjectFromStringExample
        }
        _os.setServiceProvider(_serviceProvider)
    }

    private func createPolisDirectoryFile() async throws {
        guard let polisDirectoryEntry = _serviceProvider?.directoryEntry                                                          else { throw ObjectStoreCoordinatorError.missingServiceProvider }
        guard let polisDirectory      = PolisDirectory(lastUpdateTime: Date.now, providerDirectoryEntries: [polisDirectoryEntry]) else { throw ObjectStoreCoordinatorError.missingServiceProvider }

        do {
            _serviceProviderDirectory = await ServiceProviderDirectory(polisDirectory)

            await _serviceProviderDirectory?.setDidChange()
            try await _serviceProviderDirectory?.saveToLocalProvider()
        }
        catch {
            _logger.error("Error: Cannot create POLIS Directory out of existing POLIS Directory Entry")
            throw ObjectStoreCoordinatorError.unknownError
        }
    }

    private func createObservingFacilitiesDirectoryFile() async throws {
        let polisFacilityDirectory       = PolisObservingFacilityDirectory(lastUpdateTime: Date.now, observingFacilityReferences: [])
        let observingFacilitiesDirectory = await ObservingFacilityDirectory(polisFacilityDirectory)

        do {
            _observingFacilityDirectory = observingFacilitiesDirectory
            await _observingFacilityDirectory?.setDidChange()
            try await _observingFacilityDirectory?.saveToLocalProvider()
       }
        catch {
            _logger.error("Error: Cannot create POLIS Observing Facility Directory out of existing POLIS Observing Facility Directory Entry")
            throw ObjectStoreCoordinatorError.unknownError
        }
        //TODO: Send Notification!
    }
}

//MARK: - Managing Observing Facilities -
extension ObjectStoreCoordinator {
    public func createObservingFacility(id: UUID = UUID(),
                                        observingFacilityCode: String?                                    = nil,
                                        placeInTheSolarSystem: PolisPlaceInTheSolarSystem                 = .earth,
                                        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
                                        orbitingAroundPlaceInTheSolarSystem: PolisPlaceInTheSolarSystem?  = nil,
                                        astronomicalCode: String?                                         = nil,
                                        facilityLocationID: UUID?                                         = nil) async throws-> ObservingFacility {


        let newFacilityEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(id: id,
                                                                                          observingFacilityCode: observingFacilityCode,
                                                                                          placeInTheSolarSystem: placeInTheSolarSystem,
                                                                                          gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                                          orbitingAroundPlaceInTheSolarSystem: orbitingAroundPlaceInTheSolarSystem,
                                                                                          astronomicalCode: astronomicalCode,
                                                                                          facilityLocationID: facilityLocationID)
        let newFacility      = await ObservingFacility.init(newFacilityEntry)
        

        try await newFacility.saveToLocalProvider()   // If facility's folder does not exist - creates it. No other actions!

        await _observingFacilityDirectory?.addFacility(newFacility)
        try await _observingFacilityDirectory?.saveToLocalProvider()

        return newFacility
    }
}

//MARK: - Polis Service Providing -
extension ObjectStoreCoordinator {

    func serviceProvider()              -> ServiceProvider?            { _serviceProvider }
    func serviceProviderDirectory()     -> ServiceProviderDirectory?   { _serviceProviderDirectory }
    func observingFacilitiesDirectory() -> ObservingFacilityDirectory? { _observingFacilityDirectory }

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

//MARK: Object change notifications
extension ObjectStoreCoordinator {

    // These are methods that register `ObjectStoreCoordinator` to observe various global and change notifications and
    // to post notifications, related to the persistency of the local data provider or updates by the remote service
    // provider.
    
    /// Registers `ObjectStoreCoordinator` as observer of Change Notifications posted by any `PersistentObject` instance.
    ///
    /// Depending on the framework version, data load, data format, and provider type (static or dynamic), this method
    /// might group multiple change notifications for performance reasons and process them on a background task.
    @MainActor private func startObservingRepObjectChangeNotifications() {
        _didChangeToken = _nc.addObserver(for: RepObjectDidChange.self) { message in
            //TODO: Implement me! (main-actor safe work goes here if needed)
            print(">>> Change Message Object id: \(message.payload.id, default: "unknown ID")")
        }
    }

    //TODO: We need to make this message more genera! The idea is not to calculate the payload every time depending on what object did change!
    @MainActor func post(_ payload: PolisNotificationPayload) {
        NotificationCenter.default.post(PolisObjectDidChange(payload), subject: self)
    }


    //MARK: Global notifications

    //TODO: Move this to PersistentObject!
    @MainActor func postReadyToTerminate() {
        NotificationCenter.default.post(PolisServiceProviderReadyToTerminate(), subject: self)
    }

    @MainActor private func startObservingServiceProviderReadyToTerminate() {
        _didChangeToken = _nc.addObserver(for: PolisServiceProviderReadyToTerminate.self) { _ in
            print(">>> Polis service provider ready to terminate.")
        }
    }
}

