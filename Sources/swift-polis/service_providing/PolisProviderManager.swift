
//  PolisProviderManagerManager.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.09.24.
//

import Foundation
import SoftwareEtudesUtilities

//TODO: $$$GT Add documentation
public struct PolisProviderConfiguration {
    public var reachability                                     = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name: String
    public var shortDescription: String?
    public var url: String?
    public var supportedImplementations: [PolisImplementation]? = [PolisImplementation.oldestSupportedImplementation()]
    public var providerType                                     = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental

    public var adminName: String
    public var adminEmail: String
    public var adminNote: String?

    public init(reachability: PolisDirectory.ProviderDirectoryEntry.ServiceReachability = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly,
                name: String,
                shortDescription: String?                                               = nil,
                url: String?                                                            = nil,
                supportedImplementations: [PolisImplementation]?                        = [PolisImplementation.oldestSupportedImplementation()],
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

open class PolisProviderManager {

    //MARK: Static configurations

    /// `localPolisRootPath` is the root path of the locally created POLIS provider.
    ///
    /// **Note:** `localPolisRootPath` must be set prior any other factory method is called.
    public static var localPolisRootPath = "/tmp/"

    ///  The remote Service Provider domain used to sync the static data
    ///
    ///  **Note:** The default value is set to `https://polis.observer`. This domain is guaranteed to exist.
    public static var remoteDomain       = PolisConstants.bigBangPolisDomain

    /// The (latest) version that will be used to sync working copy of the data for read access and editing
    ///
    /// Later implementations might sync also other (older) versions, but this is not required. Default implementation will use the newest possible software version.
    public static var latestWorkingPolisVersion = PolisConstants.frameworkSupportedImplementation.last

    /// Semi replacement for singleton
    ///
    /// **Note:** Make sure the public init() was called before trying to access this within the framework
    public static var currentProviderManager: PolisProviderManager!

    /// Defines the sorting method used by methods returning a list of facilities
    ///
    /// Set this ivar before calling facility related method.
    /// Default value is `none` meaning no sorting is done.
    public var facilitySortingMethod = PolisSorting.none


    //MARK: Notifications
    public struct StatusChangeNotification {
        // Provider related
        public static let providerWillCreateNotification        = Notification.Name("providerWillCreate")        // Object is the Manager
        public static let providerDidCreateNotification         = Notification.Name("providerWDidCreate")        // Object is the Manager

        public static let providerWillLoadLocalDataNotification = Notification.Name("providerWillLoadLocalData") // Object is the Manager
        public static let providerDidLoadLocalDataNotification  = Notification.Name("providerDidLoadLocalData")  // Object is the Manager

        // Facility reference related
        public static let facilityReferenceWillCreateNotification = Notification.Name("facilityReferenceWillCreate") // Object is nil
        public static let facilityReferenceDidCreateNotification  = Notification.Name("facilityReferenceDidCreate")  // Object is the ObservingFacilityReference

        // Facility detail (info) reference related
        public static let facilityInfoWillCreateNotification    = Notification.Name("facilityInfoWillCreate")    // Object is nil
        public static let facilityInfoDidCreateNotification     = Notification.Name("facilityInfoDidCreate")     // Object is the ObservingFacilityRep
        public static let facilityInfoWillLoadNotification      = Notification.Name("facilityInfoWillLoad")      // Object nil
        public static let facilityInfoDidLoadNotification       = Notification.Name("facilityInfoDidLoad")       // Object is the ObservingFacilityRep

        public static let facilityDetailWillLoadNotification    = Notification.Name("facilityDetailWillLoad")    // Object ObservingFacilityRep
        public static let facilityDetailDidLoadNotification     = Notification.Name("facilityDetailDidLoad")     // Object is the ObservingFacilityRep
        public static let facilityDetailsWillCreateNotification = Notification.Name("facilityDetailsWillCreate") // Object is nil
        public static let facilityDetailsDidCreateNotification  = Notification.Name("facilityDetailsDidCreate")  // Object is the ObservingFacilityRep

        public static let facilityDidChangeNotification         = Notification.Name("facilityInfoDidChange")     // Object is the ObservingFacilityRep

        // Artifacts
        public static let artifactWillCreateNotification       = Notification.Name("artifactWillCreate")         // Object is nil
        public static let artifactDidCreateNotification        = Notification.Name("artifactDidCreate")          // Object is the ArtifactRep
        public static let artifactWillChangeNotification       = Notification.Name("artifactWillChange")         // Object is the ArtifactRep
        public static let artifactDidChangeNotification        = Notification.Name("artifactDidChange")          // Object is the ArtifactRep

    }

    //MARK: Error definitions
    public enum PolisProviderManagerError: Error {
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
    }

    //MARK: Polis Provider Manager internal configuration
    var jsonEncoder = PrettyJSONEncoder()
    var jsonDecoder = PrettyJSONDecoder()

    let polisImplementation: PolisImplementation!
    var polisFileResourceFinder: PolisFileResourceFinder!
    var polisRemoteResourceFinder: PolisRemoteResourceFinder!

    var polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!
    var polisProviderDirectory: PolisDirectory!
    var facilityDirectory: PolisObservingFacilityDirectory!

    // Caches
    var facilities      = [ObservingFacilityRep]()
    var facilityDetails = [PolisObservingFacility]()

    /// Designate initialiser
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    init() throws {
        guard try PolisProviderManager.canConfigure() else { throw PolisProviderManagerError.cannotRegisterMultipleManagerInstances }

        self.polisImplementation = PolisProviderManager.latestWorkingPolisVersion

        if let url = URL(string: PolisProviderManager.localPolisRootPath) {
            self.polisFileResourceFinder = try PolisFileResourceFinder(at: url, supportedImplementation: self.polisImplementation)
        }
        else {
            logger.error("Cannot create URL from root folder: \(PolisProviderManager.localPolisRootPath)")
            throw PolisProviderManagerError.rootPolisPathUnaccessible
        }

        if let remoteURL = URL(string: PolisProviderManager.remoteDomain) {
            try polisRemoteResourceFinder = PolisRemoteResourceFinder(at: remoteURL, supportedImplementation: PolisConstants.frameworkSupportedImplementation.last!)
        }
        else {
            logger.error("Cannot create URL from remote service provider: \(PolisProviderManager.remoteDomain)")
            throw PolisProviderManagerError.rootPolisPathUnaccessible
        }

        PolisReference.polisFileResourceFinder   = self.polisFileResourceFinder
        PolisReference.polisRemoteResourceFinder = self.polisRemoteResourceFinder

        //TODO: This should be responsibility of the static factory methods!
        //        if !ensurePolisFoldersExistence() { throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder }
    }


    //MARK: Private stuff
    private static var isConfigured = false // check if any of the configuration methods was called

    // Utility properties
    private let nc              = NotificationCenter.default
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false
    private var data: Data?
    private var logger          = PolisLogger.shared

    private var localConfiguration: LocalConfiguration!

}

//MARK: - Configuration of the POLIS Service Provider -
public extension PolisProviderManager {

    /// Creates a new provider based on the content of the `configuration`
    ///
    /// This factory method should be used in rare cases only, mostly for testing. In most cases use
    /// `createLocalProviderByUsingExistingRemoteProvider(isExperimentalVersion:)` instead.
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    ///
    /// - Parameter configuration: contains all information needed to create a new POLIS provider
    /// - Parameter isExperimentalVersion: defines if the new provider is a sandbox for experimenting or enhancing the standard 
    /// - Returns: an instance of `PolisProviderManager`
    static func createLocalProviderWith(configuration: PolisProviderConfiguration, isExperimentalVersion: Bool = false) throws -> PolisProviderManager? {
        let nc = NotificationCenter.default

        _ = try canConfigure()

        // 1. Make sure no POLIS data already exists
        let manager = try PolisProviderManager()
        if manager.ensureMinimalLocalPolisConfiguration() { throw PolisProviderManagerError.providerAtTheSameRootPathAlreadyConfigured }
        nc.post(name: StatusChangeNotification.providerWillCreateNotification, object: manager)

        // 2. Create POLIS Folders
        if !manager.ensurePolisFoldersExistence() { throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder }

        // 3. Create Configuration instances and Provider data
        let admin     = PolisPerson(name: configuration.adminName, email: configuration.adminEmail, note: configuration.adminNote)
        let directory = try PolisDirectory.ProviderDirectoryEntry(name: configuration.name,
                                                                  supportedImplementations: [PolisImplementation.oldestSupportedImplementation()],
                                                                  providerType: configuration.providerType,
                                                                  contact: admin)

        try manager.newLocalConfiguration(isEditable: true , isTesting: isExperimentalVersion)
        try manager.updateLocalConfiguration()
        PolisProviderManager.currentProviderManager = manager

        // 4. Create the provider root
        manager.polisProviderConfigurationEntry = directory
        try manager.flush(item: manager.polisProviderConfigurationEntry)

        // 5. Create the provider directory
        manager.polisProviderDirectory = PolisDirectory(providerDirectoryEntries: [manager.polisProviderConfigurationEntry])
        try manager.flush(item: manager.polisProviderDirectory)

        // 6. Create facility directory
        manager.facilityDirectory = PolisObservingFacilityDirectory(lastUpdate: Date.now, observingFacilityReferences: [])
        try manager.flush(item: manager.facilityDirectory)

        // 7. Finalise
        nc.post(name: StatusChangeNotification.providerDidCreateNotification, object: self)
        isConfigured = true

        return manager
    }

    /// This method should be used by non data editing clients (e.g. mobile apps) trying to load the initial batch of POLIS data
    ///
    /// In client apps use this method only once. Use `cachedProvider()` in subsequent launches of the client app.
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    ///
    /// - Parameter useExperimentalVersion: if `true` it tries to connect to a well known experimental test server
    static func createLocalProviderByUsingExistingRemoteProvider(isExperimentalVersion: Bool = false, isEditable: Bool = false) async throws -> PolisProviderManager? {
        _ = try canConfigure()

        //FIXME: Act as if there is no remote server
        throw PolisProviderManagerError.noRemoteDataFound

        //TODO: Implement the `isEditable` functionality as part of the syncing/config file / struct
        //TODO: 0. Make sure no local data exist that could be overwritten!

        //TODO: 1. Check if the remote provider is set. If not use one of the framework provided starting "BigBang" sites

        //TODO: Implement me!

//        isConfigured = true

//        return nil
    }

    /// If there is already an existing local copy of the POLIS dataset use this method to access it
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    static func useExistingLocalProvider() throws -> PolisProviderManager {
        let nc = NotificationCenter.default

        _ = try canConfigure()

        // 1. Make sure POLIS data already exists
        let manager = try PolisProviderManager()
        if !manager.ensureMinimalLocalPolisConfiguration() { throw PolisProviderManagerError.requiredPolisDataMissing }
        PolisProviderManager.currentProviderManager = manager

        nc.post(name: StatusChangeNotification.providerWillLoadLocalDataNotification, object: manager)

        // 0. Load the configuration data
        try manager.loadLocalConfiguration()

        // 1. Check and try to load the provider root
        manager.polisProviderConfigurationEntry = try PolisDirectory.ProviderDirectoryEntry.loadFromLocalFileSystemUsing(manager: manager) as? PolisDirectory.ProviderDirectoryEntry

        // 2. Check and try to load the provider directory
        manager.polisProviderDirectory = try PolisDirectory.loadFromLocalFileSystemUsing(manager: manager) as? PolisDirectory

        // 3. Check and try to load the facility directory
        manager.facilityDirectory = try PolisObservingFacilityDirectory.loadFromLocalFileSystemUsing(manager: manager) as? PolisObservingFacilityDirectory

        // 4. Prepare the list of all currently available observing facilities
        for facility in manager.facilityDirectory!.observingFacilityReferences {
//            let observingFacility = try ObservingFacilityRep.findOrRegisterObservingFacilityWith(identity: facility.identity)
        }

        // 5: Post a notification that the local copy is ready to be used and finalise
        isConfigured = true
        PolisProviderManager.currentProviderManager = manager
        nc.post(name: StatusChangeNotification.providerDidLoadLocalDataNotification, object: manager)

        //TODO: 5. If needed, sync with remote providers
        // Q: Do we need to create Remote Server Initial Data? Perhaps this is a choice of the Provider Owner?

        return manager
    }

    internal func flush(item: any StorableItem) throws {
        var currentItem: (any StorableItem)? = item

        while currentItem != nil {
            try currentItem?.flashUsing(manager: self)
            currentItem = currentItem?.parentItem()
        }
    }

    /// Call this method before terminating the process and wait for the notification
    ///
    /// In order to avoid data inconsistency, or loss of new or updated data, always call this method before exiting the process (tool or app, and wait for the notification. If
    /// exception is thrown, and the process is updating the local data, notify the user for the possibility that the data might be inconsistent. If the process is read-only,
    /// automatic data recovery will be performed next time the process is executed.
    func prepareToTerminate() async throws {
        //TODO: Implement me!
        //TODO: Perhaps we need a delegate to complete the task? Like execute the script that Douglas is writing? The delegate
        // should have methods to sync different POLIS files one by one if they are modified.
        //TODO: N. Post ReadyToTerminate notification.
    }

    #if DEBUG
    static func prepareForTesting() {
        isConfigured           = false
        currentProviderManager = nil
    }
    #endif
    
    //MARK: Private stuff
    private static func canConfigure() throws -> Bool {
        if isConfigured || (PolisProviderManager.currentProviderManager != nil) {
            throw PolisProviderManagerError.providerAtTheSameRootPathAlreadyConfigured
        }
        return true
    }
}

//MARK: - Working with Observing Facilities -
public extension PolisProviderManager {

    /// Try to add or delete a facility only if `canAddOrDeleteFacility()` returns `true`
    ///
    /// In case one attempts to add or delete a facility hen the method returns `false`, exception will be thrown.
//    func canAddOrDeleteFacility() -> Bool { PolisDirectory.isSynced && PolisObservingFacilityDirectory.isSynced }
    //FIXME: Needs proper implementation!
    func canAddOrDeleteFacility() -> Bool { true }

    /// Initially all `ObservingFacilityRep` (and subclasses) are not fully loaded. Ca;; `loadData()` and observe status change notifications to ensure all
    /// detail data is fully loaded and synced.
    func allFacilities() -> [ObservingFacilityRep] {
        //TODO: Sorting!
        return facilities
    }

    /// Returns the `ObservingFacilityReference` of the facility stored into the facility directory or nil if it is not found.
    func directoryEntryForFacilityWith(id: UUID) -> PolisObservingFacilityDirectory.ObservingFacilityReference? {
        for anEntry in facilityDirectory.observingFacilityReferences {
            if anEntry.id == id { return anEntry }
        }
        return nil
    }
}

//MARK: - Working with files and folders -
extension PolisProviderManager {

    /// This method returns all currently possible POLIS directories. Use it whenever the list is needed.
    private func polisDirectoryPaths() -> [String] {
        [
            polisFileResourceFinder.baseFolder(),                        // ../polis/
            polisFileResourceFinder.observingFacilitiesFolder(),         // ../polis/<version>/polis_observing_facilities/
            polisFileResourceFinder.resourcesFolder(),                   // ../polis/<version>/polis_resources/
            polisFileResourceFinder.ownersFolder(),                      // ../polis/<version>/polis_owners/
            polisFileResourceFinder.manufacturersFolder(),               // ../polis/<version>/polis_manufacturers/
        ]
    }

    /// This method returns all currently possible POLIS essential files required by the standard. Use it whenever the list is needed.
    private func essentialPolisFiles() -> [String] {
        [
            configurationFilePath(),                                     // ./polis_config.json
            polisFileResourceFinder.configurationFile(),                 // ../polis/polis.json
            polisFileResourceFinder.polisProviderDirectoryFile(),        // ../polis/polis_directory.json
            polisFileResourceFinder.observingFacilitiesDirectoryFile(),  // ../polis/<version>/polis_observing_facilities.json
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
    private func ensureMinimalLocalPolisConfiguration() -> Bool {
        return checkPolisDirectoryPathsExistence(paths: polisDirectoryPaths()) && checkPolisFilesExistence(paths: essentialPolisFiles())
    }
}

//MARK: - Working with LocalConfiguration
extension PolisProviderManager {
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

        localConfiguration = config
        try updateLocalConfiguration()
    }

    private func updateLocalConfiguration() throws {
        localConfiguration.lastSyncDate = Date.now

        do    { data = try jsonEncoder.encode(localConfiguration) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Configuration Data")
            throw PolisProviderManager.PolisProviderManagerError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: configurationFilePath(), contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Configuration Data to: \(configurationFilePath())")
            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
        }
    }

    private func loadLocalConfiguration() throws {
        if fm.fileExists(atPath: configurationFilePath()) {
            let data = fm.contents(atPath: configurationFilePath())

            if let data = data {
                if let result = try? jsonDecoder.decode(LocalConfiguration.self, from: data) { localConfiguration = result }
                else {
                    logger.error("Error: cannot load POLIS configuration data at - \(configurationFilePath())")
                    throw PolisProviderManagerError.cannotEncodePolisType }
            }
            else {
                logger.error("Error: POLIS configuration data does not exist at path - \(configurationFilePath())")
                throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFile }
        }
    }

    private func configurationFilePath() -> String { "\(polisFileResourceFinder.rootFolder())\(PolisConstants.polisLocalConfigFileName)" }
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

extension LocalConfiguration {
    public enum CodingKeys: String, CodingKey {
        case remoteSyncServer = "remote_sync_server"
        case isEditable       = "is_editable"
        case isTesting        = "is_testing"
        case lastSyncDate     = "last_syncDate"
        case lastSyncResult   = "last_sync_result"
    }
}
