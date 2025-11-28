//
//  ObjectStore.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation
import SoftwareEtudesUtilities

@MainActor public var sharedObjectStore: ObjectStore!

public actor ObjectStore {

    //MARK: - Public APIs -

    public enum ObjectStoreError: Error {
        case localStoreAlreadyExists
        case localStoreNotFound
        case cannotRegisterMultipleManagerInstances
        case rootPolisPathUnaccessible
        case requiredPolisDataMissing
        case noRemoteDataFound
        case cannotAccessOrCreateStandardPolisFolder
        case cannotAccessOrCreateStandardPolisFile
        case providerAtTheSameRootPathAlreadyConfigured // Thrown by attempting to call multiple configuration methods
        case cannotEncodePolisType                      // JSON encoding
        case cannotDecodePolisType                      // JSON decoding
        case cannotWriteFile
        case polisDataMismatch                          // e.g. expects Earth based observatory but gets a Mars rover
        case fileIO                                     // e.g. create/remove folders and files
        case missingRequiredID
        case polisObjectOfTheTypeAlreadyExists
        case objectCannotBeEdited
        case objectWithIDNotFound
   }


    // Resource finders
    public func fileResourceFinder() -> PolisFileResourceFinder     { _fileResourceFinder }
    public func remoteResourceFinder() throws -> PolisRemoteResourceFinder {
        if _remoteResourceFinder == nil {
            if _localConfiguration != nil {
                let domain = _localConfiguration.isTesting ? PolisConstants.testBigBangPolisDomain : PolisConstants.bigBangPolisDomain
                _remoteResourceFinder = try PolisRemoteResourceFinder(at: URL(string: domain)!,
                                                                  supportedImplementation: polisFrameworkSupportedImplementation.last!)
            }
        }
       return _remoteResourceFinder
    }

    // Local configuration
    public func polisProviderConfigurationEntry() -> PolisDirectory.ProviderDirectoryEntry { _polisProviderConfigurationEntry }
    public func setPolisProviderConfigurationEntry(_ entry: PolisDirectory.ProviderDirectoryEntry) { _polisProviderConfigurationEntry = entry }


    // Service Provider Configuration
    public func isConfigured() -> Bool {
        if _isConfigured != nil { return _isConfigured! }
        else                    { return localStoreExists() }
    }

    /// Creates a local store. If remote store does not exists, this method will try to create it by using external delegate class (not yet implemented)
    public func createLocalStore(providerConfiguration: ProviderConfiguration,
                                 isEditable     : Bool    = true,
                                 isTesting      : Bool    = false,
                                 isExperimental : Bool    = false) async throws {
        if isConfigured() { throw ObjectStoreError.localStoreAlreadyExists }

        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillCreateNotification, object: self)

        // 1. Create POLIS Folders
        if !ensurePolisFoldersExistence() { throw ObjectStoreError.cannotAccessOrCreateStandardPolisFolder }

        // 2. Create Configuration instances and Provider data
        let admin     = PolisPerson(name: providerConfiguration.adminName,
                                    email: providerConfiguration.adminEmail,
                                    note: providerConfiguration.adminNote)
        let directory = try PolisDirectory.ProviderDirectoryEntry(name: providerConfiguration.name,
                                                                  supportedImplementations: [PolisImplementation.latestSupportedImplementation()],
                                                                  providerType: providerConfiguration.providerType,
                                                                  contact: admin)

        try await newLocalConfiguration(remoteSyncServer: URL(string: providerConfiguration.url ?? PolisConstants.testBigBangPolisDomain),
                                  isEditable: isEditable,
                                  isTesting: isTesting)
        try await updateLocalConfiguration()

        // 3. Create the provider root
        _polisProviderConfigurationEntry = directory
        try await flush(item: _polisProviderConfigurationEntry)

        // 4. Create the provider directory
        _polisProviderDirectory = PolisDirectory(providerDirectoryEntries: [_polisProviderConfigurationEntry])
        try await flush(item: _polisProviderDirectory)

        // 5. Create facility directory
        _facilityDirectory = PolisObservingFacilityDirectory(lastUpdate: Date.now, observingFacilityReferences: [])
        try await flush(item: _facilityDirectory)

        configureRelatedTypesAfterStoreInitialisation()
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidCreateNotification, object: self)
        _isConfigured = true
    }

    /// If the local object store exists (is cached) this method will start loading local data immediately. When initial loading is finished, the method will check for
    /// changes with the remote store and if some are found, a syncing process will start. If there is no local store, data will be first copied from the remote store,
    /// and once copied, they will be loaded. This process could be slow.
    ///
    /// Loading always will be step-by-step and will start with the most important data and later will continue with detail data.
    public func loadLocalStoreAt(path: String) async throws {
        _fileResourceFinder = try PolisFileResourceFinder(at: URL(string: path)!, supportedImplementation: polisFrameworkSupportedImplementation.last!)

        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillLoadNotification, object: self)


        // N. Finally, configure related classes
        configureRelatedTypesAfterStoreInitialisation()

        // N. Load store configuration
        try loadLocalConfiguration()
        if !localStoreExists() {
            logger.error("loadLocalStore - Local store does not exist or misconfigured")
            throw ObjectStoreError.localStoreNotFound
        }
        if let provider = try await PolisDirectory.ProviderDirectoryEntry.loadFromLocalFileSystemUsing(store: self) as? PolisDirectory.ProviderDirectoryEntry {
            _polisProviderConfigurationEntry = provider
        }

        // N. Load Service Provider Directory
        if let providerDirectory = try await PolisDirectory.loadFromLocalFileSystemUsing(store: self) as? PolisDirectory {
            _polisProviderDirectory = providerDirectory
        }

        // N. Load Facility Directory
        if let facilityDirectory = try await PolisObservingFacilityDirectory.loadFromLocalFileSystemUsing(store: self) as? PolisObservingFacilityDirectory {
            _facilityDirectory = facilityDirectory
        }

        // N. For each Facility Ref from the Facility Directory create a minimal Facility object and initiate its Loading
        for anEntry in _facilityDirectory.observingFacilityReferences {
            let aFacility = try ObservingFacility(facilityReference: anEntry, store: self)
            _facilities.append(aFacility)
            try await aFacility.loadData()
        }

        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidLoadNotification, object: self)
    }

    public func loadLocalStoreFromRemoteProvider(localPath: String) async throws {
        //TODO: Implement me!

        // N. Finally, configure related classes
        configureRelatedTypesAfterStoreInitialisation()
    }

    /// Removes unconditionally local data.
    ///
    /// Throws an error if the data cannot be removed.
    public func removeExistingLocalStore() async throws {
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillRemoveNotification, object: self)

        do {
            try fm.removeItem(atPath: configurationFilePath())
            try fm.removeItem(atPath: _fileResourceFinder.baseFolder())
        }
        catch {
            logger.error("removeExistingLocalStore - Cannot remove existing local store: \(error.localizedDescription)")
            throw ObjectStoreError.fileIO
        }
        _isConfigured = false
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidRemoveNotification, object: self)
    }

    public func isEditable() -> Bool { _localConfiguration.isTesting || _localConfiguration.isEditable }

    /// Makes sure that all edited (in memory) objects are stored persistently in the local Store
    public func close() async throws {
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillCloseNotification, object: self)

        _localConfiguration              = nil
        _polisProviderConfigurationEntry = nil
        _polisProviderDirectory          = nil
        _facilityDirectory               = nil
        _facilities.removeAll()

        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidCloseNotification, object: nil)
    }

    //MARK: - Non-public APIs -

    //MARK: Polis Provider Manager internal configuration
    let jsonEncoder = PrettyJSONEncoder()
    let jsonDecoder = PrettyJSONDecoder()

    @MainActor init(fileResourceFinder: PolisFileResourceFinder, remoteResourceFinder: PolisRemoteResourceFinder) async {
        self._fileResourceFinder        = fileResourceFinder
        self._remoteResourceFinder      = remoteResourceFinder
        sharedObjectStore = self

        await assignStoreToStaticProperties()
    }

    // POLIS related
    func facilityDirectory() -> PolisObservingFacilityDirectory { _facilityDirectory! }


    func flush(item: any StorableItem) async throws {
        var currentItem: (any StorableItem)? = item

        while currentItem != nil {
            try await currentItem?.flashUsing(store: self)
            currentItem = try await currentItem?.parentItem(store: self)
        }
    }

    //MARK: - Private APIs -
    private let nc              = NotificationCenter.default
    private let logger          = SEPolisLogger.logger("ObjectStore")
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false
    private var data: Data?


    @MainActor static private var _currentObjectStore: ObjectStore!
    private var _isConfigured: Bool?
    private var _fileResourceFinder: PolisFileResourceFinder!
    private var _remoteResourceFinder: PolisRemoteResourceFinder!

    private var _localConfiguration: LocalConfiguration!

    // Polis Object Cach
    private var _polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!
    private var _polisProviderDirectory: PolisDirectory!
    private var _facilityDirectory: PolisObservingFacilityDirectory!

    // Cached objects
    private var _facilities = [ObservingFacility]()

    private func configureRelatedTypesAfterStoreInitialisation() {
        PersistentObject.polisFileResourceFinder   = _fileResourceFinder
        PersistentObject.polisRemoteResourceFinder = _remoteResourceFinder
    }
}

//MARK: - Facility related -
extension ObjectStore {
    /// List of all currently in-memory Facilities
    ///
    /// The list might not contain remote Facilities that are not yet fetched from the remote Provider.
    /// - Returns: Possibly empty array of Facilities
    public func facilities() -> [ObservingFacility] { _facilities }

    /// Creates the Facility Reference and the Facility object
    public func createFixedEarthBasedFacility(name: String? = nil) async throws  -> ObservingFacility {
        try await createFacility(name: name,gravitationalBodyRelationship: .surfaceFixed, placeInTheSolarSystem: .earth)
    }

    public func createFacility(
        name: String?                                                     = PolisConstants.unknownObject,
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) async throws -> ObservingFacility {
        let facility = try ObservingFacility(id: UUID(), name: name, store: self)

        facility.gravitationalBodyRelationship = gravitationalBodyRelationship
        facility.placeInTheSolarSystem         = placeInTheSolarSystem
        try await facility.startEditing()

        try await addOrUpdateObservingFacilityDirectoryEntry(ObservingFacilityEntry(from: facility))
        _facilities.append(facility)
        try await facility.saveChanges()

        return facility
    }
    
    /// Tries to find a Facility with specified ID
    ///
    /// - Parameter id: the ID  of the Facility
    /// - Returns: if the Facility is found, it is returned, otherwise nil
    public func facilityWithId(_ id: UUID)  -> ObservingFacility? {
        for aFacility in _facilities {
            if aFacility.id == id { return aFacility }
        }
        return nil
    }

    func addOrUpdateObservingFacilityDirectoryEntry(_ facility: ObservingFacilityEntry) async throws {
        if let index = _facilityDirectory.observingFacilityReferences.firstIndex(where: {$0.id == facility.id} ) {
            var ref = _facilityDirectory.observingFacilityReferences[index]

            ref.identity.externalReferences    = facility.identity.externalReferences
            ref.identity.lastUpdateTime        = facility.identity.lastUpdateTime
            ref.identity.name                  = facility.identity.name
            ref.identity.localName             = facility.identity.localName
            ref.identity.abbreviation          = facility.identity.abbreviation
            ref.identity.shortDescription      = facility.identity.shortDescription
            ref.identity.startTime             = facility.identity.startTime
            ref.identity.endTime               = facility.identity.endTime
            ref.identity.polisRegistrationTime = facility.identity.polisRegistrationTime

            _facilityDirectory.observingFacilityReferences.remove(at: index)
            _facilityDirectory.observingFacilityReferences.append(ref)
        }
        else {
            let newRef = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: facility.identity,
                                                                                    gravitationalBodyRelationship: facility.gravitationalBodyRelationship,
                                                                                    placeInTheSolarSystem: facility.placeInTheSolarSystem)
            _facilityDirectory.observingFacilityReferences.append(newRef)
        }

        _facilityDirectory.lastUpdate = Date.now
        try await _facilityDirectory.flashUsing(store: self)
    }

}

//MARK: - Working with files and folders -
extension ObjectStore {

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
                if !(fm.fileExists(atPath: path, isDirectory: &isDir) && (isDir.boolValue)) {
                    try fm.createDirectory(atPath: path, withIntermediateDirectories: true)
                }
            }
            return true
        }
        catch {
            logger.error("Error: cannot access or create folder - \(error.localizedDescription)")
            return false
        }
    }

    private func ensurePolisFoldersExistence()  -> Bool { tryToEnsureFoldersExistence(paths: polisDirectoryPaths()) }

    private func checkPolisDirectoryPathsExistence(paths: [String]) -> Bool {
        for path in paths {
            if !(fm.fileExists(atPath: path, isDirectory: &isDir) && (isDir.boolValue)) {
                return false
            }
        }

        return true
    }

    private func checkPolisFilesExistence(paths: [String]) -> Bool {
        for path in paths {
            if !fm.isReadableFile(atPath: path) { return false }
        }

        return true
    }

    /// If `true` we can start loading data or doing other changes to the local POLIS provider
    private func localStoreExists() -> Bool {
        let configFileExists = fm.isReadableFile(atPath: configurationFilePath())

        let result = (configFileExists &&
                      checkPolisDirectoryPathsExistence(paths: polisDirectoryPaths()) &&
                      checkPolisFilesExistence(paths: essentialPolisFiles()))

        if result { _isConfigured = true }

        return result
    }

    private func assignStoreToStaticProperties() async {
//        PersistentObject.store = self
    }
}

//MARK: - ProviderConfiguration -
public struct ProviderConfiguration {
    public var reachability                                     = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name: String
    public var shortDescription: String?
    public var url: String?
    public var supportedImplementations: [PolisImplementation]? = [PolisImplementation.latestSupportedImplementation()]
    public var providerType                                     = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental

    public var adminName: String
    public var adminEmail: String
    public var adminNote: String?

    public init(reachability: PolisDirectory.ProviderDirectoryEntry.ServiceReachability = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly,
                name: String,
                shortDescription: String?                                               = nil,
                url: String?                                                            = nil,
                supportedImplementations: [PolisImplementation]?                        = [PolisImplementation.latestSupportedImplementation()],
                providerType:PolisDirectory.ProviderDirectoryEntry.ProviderType         = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental,
                adminName: String,
                adminEmail: String,
                adminNote: String?                                                      = nil) {
        self.reachability             = reachability
        self.name                     = name
        self.shortDescription         = shortDescription
        self.url                      = url
        self.supportedImplementations = supportedImplementations
        self.providerType             = providerType
        self.adminName                = adminName
        self.adminEmail               = adminEmail
        self.adminNote                = adminNote
    }
}

//MARK: - Working with LocalConfiguration
extension ObjectStore {
    private func newLocalConfiguration(remoteSyncServer: URL? = nil, isEditable: Bool, isTesting: Bool) async throws {
        var remoteURL: URL

        if let url = remoteSyncServer { remoteURL = url }
        else {
            if isTesting { remoteURL = URL(string: PolisConstants.testBigBangPolisDomain)! }
            else         { remoteURL = URL(string: PolisConstants.bigBangPolisDomain)! }
        }

        let config = LocalConfiguration(remoteSyncServer: remoteURL,
                                        isEditable: isEditable,
                                        isTesting: isTesting,
                                        lastSyncDate: Date.now,
                                        lastSyncResult: .neverSynced)

        _localConfiguration = config
        try await updateLocalConfiguration()
    }

    private func updateLocalConfiguration() async throws {
        let configPath = configurationFilePath()
        
        do    { data = try jsonEncoder.encode(_localConfiguration) }
        catch {
            logger.error("updateLocalConfiguration - Cannot encode POLIS Configuration Data")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: configPath, contents: data)  {
            logger.error("updateLocalConfiguration - Cannot save POLIS Configuration Data to: \(configPath)")
            throw ObjectStore.ObjectStoreError.cannotWriteFile
        }
        _localConfiguration.lastSyncDate = Date.now
    }

    private func loadLocalConfiguration() throws {
        if fm.fileExists(atPath: configurationFilePath()) {
            let data = fm.contents(atPath: configurationFilePath())

            if let data = data {
                if let result = try? jsonDecoder.decode(LocalConfiguration.self, from: data) { _localConfiguration = result }
                else {
                    logger.error("ObjectStore:loadLocalConfiguration - cannot load POLIS configuration data at - \(configurationFilePath())")
                    throw ObjectStore.ObjectStoreError.cannotEncodePolisType }
            }
            else {
                logger.error("ObjectStore:loadLocalConfiguration - POLIS configuration data does not exist at path - \(configurationFilePath())")
                throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }
        }
    }

    private func configurationFilePath() -> String { "\(_fileResourceFinder.rootFolder())\(PolisConstants.polisLocalConfigFileName)" }
}

fileprivate struct LocalConfiguration: Codable {
    enum SyncResult: String, Codable {
        case success
        case partiallySynced = "partially_synced"
        case noContention    = "no_contention"
        case failed
        case neverSynced     = "never_synced"
    }

    var remoteSyncServer: URL?
    var isEditable: Bool
    var isTesting: Bool
    var lastSyncDate: Date?
    var lastSyncResult: SyncResult?
}

fileprivate extension LocalConfiguration {
    enum CodingKeys: String, CodingKey {
        case remoteSyncServer = "remote_sync_server"
        case isEditable       = "is_editable"
        case isTesting        = "is_testing"
        case lastSyncDate     = "last_syncDate"
        case lastSyncResult   = "last_sync_result"
    }
}

