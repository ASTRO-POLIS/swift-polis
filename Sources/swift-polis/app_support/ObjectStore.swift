//
//  ObjectStore.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation
import SoftwareEtudesUtilities

public actor ObjectStore {

    //MARK: - Public APIs -
    public static func currentObjectStore() -> ObjectStore { _currentObjectStore }

    public enum ObjectStoreError: Error {
        case localStoreAlreadyExists
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
   }


    // Resource finders
    public func fileResourceFinder() -> PolisFileResourceFinder     { _fileResourceFinder }
    public func remoteResourceFinder() -> PolisRemoteResourceFinder { _remoteResourceFinder }

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

        try newLocalConfiguration(remoteSyncServer: URL(string: providerConfiguration.url ?? PolisConstants.testBigBangPolisDomain),
                                  isEditable: isEditable,
                                  isTesting: isTesting)
        try updateLocalConfiguration()

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
    public func loadLocalStore() async throws {
        //TODO: Implement me!
    }

    /// Removes unconditionally local data.
    ///
    /// Throws an error if the data cannot be removed.
    public func removeExistingLocalStore() throws {
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillRemoveNotification, object: self)

        do {
            try fm.removeItem(atPath: configurationFilePath())
            try fm.removeItem(atPath: _fileResourceFinder.baseFolder())
        }
        catch {
            PolisLogger.shared.error("ObjectStore:removeExistingLocalStore - Cannot remove existing local store: \(error.localizedDescription)")
            throw ObjectStoreError.fileIO
        }
        _isConfigured = false
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidRemoveNotification, object: self)
    }

    public func isEditable() -> Bool { _localConfiguration.isTesting || _localConfiguration.isEditable }

    /// Makes sure that all edited (in memory) objects are stored persistently in the local Store
    public func close() async throws {
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreWillCloseNotification, object: self)
        //TODO: Implement me!
        nc.post(name: AppSupportStatusChangeNotification.ObjectStoreDidCloseNotification, object: nil)
    }

    //MARK: - Non-public APIs -
    // POLIS related
    func facilityDirectory() -> PolisObservingFacilityDirectory { _facilityDirectory! }

    func addOrUpdateObservingFacility(reference: PolisObservingFacilityDirectory.ObservingFacilityReference) async throws{
        var dir = _facilityDirectory!
        var refs = dir.observingFacilityReferences

        if let index = dir.observingFacilityReferences.firstIndex(where: {$0.id == reference.id} ) {
            refs[index].identity.externalReferences    = reference.identity.externalReferences
            refs[index].identity.lastUpdateTime        = reference.identity.lastUpdateTime
            refs[index].identity.name                  = reference.identity.name
            refs[index].identity.localName             = reference.identity.localName
            refs[index].identity.abbreviation          = reference.identity.abbreviation
            refs[index].identity.shortDescription      = reference.identity.shortDescription
            refs[index].identity.startTime             = reference.identity.startTime
            refs[index].identity.endTime               = reference.identity.endTime
            refs[index].identity.polisRegistrationTime = reference.identity.polisRegistrationTime
        }
        
        dir.lastUpdate = Date.now
        dir.observingFacilityReferences.append(reference)
        try await dir.flashUsing(store: self)
    }
        
    //MARK: Polis Provider Manager internal configuration
    let jsonEncoder = PrettyJSONEncoder()
    let jsonDecoder = PrettyJSONDecoder()

    init(fileResourceFinder: PolisFileResourceFinder, remoteResourceFinder: PolisRemoteResourceFinder) async {
        self._fileResourceFinder        = fileResourceFinder
        self._remoteResourceFinder      = remoteResourceFinder
        ObjectStore._currentObjectStore = self

        await assignStoreToStaticProperties()
    }

    func flush(item: any StorableItem) async throws {
        var currentItem: (any StorableItem)? = item

        while currentItem != nil {
            try await currentItem?.flashUsing(store: self)
            currentItem = await currentItem?.parentItem(store: self)
        }
    }

    //MARK: - Private APIs -
    private let nc              = NotificationCenter.default
    private var logger          = PolisLogger.shared
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false
    private var data: Data?


    static private var _currentObjectStore: ObjectStore!
    private var _isConfigured: Bool?
    private var _fileResourceFinder: PolisFileResourceFinder
    private var _remoteResourceFinder: PolisRemoteResourceFinder

    private var _localConfiguration: LocalConfiguration!

    // Polis Object Cach
    private var _polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!
    private var _polisProviderDirectory: PolisDirectory!
    private var _facilityDirectory: PolisObservingFacilityDirectory!


    private func configureRelatedTypesAfterStoreInitialisation() {
        // PersistentObject
        PersistentObject.store                     = self
        PersistentObject.polisFileResourceFinder   = _fileResourceFinder
        PersistentObject.polisRemoteResourceFinder = _remoteResourceFinder
    }
}

//MARK: - Facility related -
extension ObjectStore {
    /// Creates the Facility Reference and the Facility
    public func createFixedEarthBasedFacility() async throws  -> ObservingFacility {
        try await createFacility(gravitationalBodyRelationship: .surfaceFixed, placeInTheSolarSystem: .earth)
    }

    public func createFacility(
        gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
        placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth
    ) async throws -> ObservingFacility {
        let facility = try await ObservingFacility(id: UUID(), name: "<unnamed>")

        facility.gravitationalBodyRelationship = gravitationalBodyRelationship
        facility.placeInTheSolarSystem = placeInTheSolarSystem

        try await facility.saveChanges()

        return facility
    }

    public func facilityWithId(_ id: String, shouldAutoload: Bool = true) async throws  { //TODO: Should return a facility
        //TODO: Implement me!
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
        let configFileExists = !fm.isReadableFile(atPath: configurationFilePath())

        let result = (configFileExists &&
                      checkPolisDirectoryPathsExistence(paths: polisDirectoryPaths()) &&
                      checkPolisFilesExistence(paths: essentialPolisFiles()))

        if result { _isConfigured = true }

        return result
    }

    private func assignStoreToStaticProperties() async {
        PersistentObject.store = self
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
    private func newLocalConfiguration(remoteSyncServer: URL? = nil, isEditable: Bool, isTesting: Bool) throws {
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
        try updateLocalConfiguration()
    }

    private func updateLocalConfiguration() throws {
        do    { data = try jsonEncoder.encode(_localConfiguration) }
        catch {
            PolisLogger.shared.error("ObjectStore:updateLocalConfiguration - Cannot encode POLIS Configuration Data")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: configurationFilePath(), contents: data) {
            PolisLogger.shared.error("ObjectStore:updateLocalConfiguration - Cannot save POLIS Configuration Data to: \(configurationFilePath())")
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
