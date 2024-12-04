//
//  PolisProviderManagerManager.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.09.24.
//

import Foundation
import SoftwareEtudesUtilities

protocol StorableItem {
    func parentItem() -> (any StorableItem)?
    mutating func flashUsing(manager: PolisProviderManager) async throws
}


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

public final class PolisProviderManager {

    //MARK: Notifications
    public struct StatusChangeNotifications {
        public static let providerWillCreateNotification = Notification.Name("providerWillCreate")  // Object is the Manager
        public static let providerDidCreateNotification  = Notification.Name("providerWDidCreate")
    }

    //MARK: Error definitions
    public enum PolisProviderManagerError: Error {
        case cannotRegisterMultipleManagerInstances
        case cannotAccessOrCreateStandardPolisFolder
        case providerAtTheSameRootPathAlreadyConfigured // Thrown by attempting to call multiple configuration methods
        case cannotEncodePolisType                      // JSON encoding
        case cannotWriteFile
    }

    /// `localPolisRootPath` is the root path of the locally created POLIS provider.
    ///
    /// `localPolisRootPath` must be set before any other factory method is called.
    public static var localPolisRootPath: String = "/tmp/"

    /// The version that will be used to sync working copy of the data for read access and editing
    ///
    /// Later implementations might sync also other versions, but this is not required. Default implementation will use the newest possible software version.
    public static var workingPolisVersion = PolisConstants.frameworkSupportedImplementation.last

    /// Semi replacement for singleton
    ///
    /// Make sure the public init() was called before trying to access this within the framework
    static var currentProviderManager: PolisProviderManager!

    //MARK: Polis Provider Manager internal configuration
    var jsonEncoder = PrettyJSONEncoder()
    var jsonDecoder = PrettyJSONDecoder()

    let polisImplementation: PolisImplementation!
    var polisFileResourceFinder: PolisFileResourceFinder!
    var polisRemoteResourceFinder: PolisRemoteResourceFinder!

    var polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!
    var polisProviderDirectory: PolisDirectory!
    var facilityDirectory: PolisObservingFacilityDirectory!

    /// Designate initialiser
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    init() throws {
        guard PolisProviderManager.currentProviderManager == nil else { throw PolisProviderManagerError.cannotRegisterMultipleManagerInstances }

        self.polisImplementation = PolisProviderManager.workingPolisVersion

        if let url = URL(string: PolisProviderManager.localPolisRootPath) {
            self.polisFileResourceFinder = try PolisFileResourceFinder(at: url, supportedImplementation: self.polisImplementation)
        } else {
            logger.error("Cannot create URL from rootFolder")
            throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }

        if !ensurePolisFoldersExistence() { throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder }

        PolisProviderManager.currentProviderManager = self
    }

    //MARK: Private stuff
    // Utility properties
    private let nc              = NotificationCenter.default
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false
    private var logger          = PolisLogger.shared


    private var isConfigured    = false // check if any of the configuration methods was called

}

//MARK: - Configuration of the POLIS Service Provider -
public extension PolisProviderManager {

    /// Creates a new provider based on the content of the `configuration`
    ///
    /// This factory method should be used in rare cases only, mostly for testing. In most cases use
    /// `createLocalProviderByUsingExistingRemoteProvider(usingExperimentalVersion:)` instead.
    ///
    /// - Parameter configuration: contains all information needed to create a new POLIS provider
    /// - Returns: an instance of `PolisProviderManager`
    func createLocalProvider(configuration: PolisProviderConfiguration) async throws {
        try canConfigure()

        //TODO: Throw if something exists (Hasmik's suggestion)

        let admin     = PolisPerson(name: configuration.adminName, email: configuration.adminEmail, note: configuration.adminNote)
        let directory = try PolisDirectory.ProviderDirectoryEntry(name: configuration.name,
                                                                  supportedImplementations: [PolisImplementation.oldestSupportedImplementation()],
                                                                  providerType: configuration.providerType,
                                                                  contact: admin)

        nc.post(name: StatusChangeNotifications.providerWillCreateNotification, object: self)
        
        // 1. Create the provider configuration entry
        polisProviderConfigurationEntry = directory
        try await flush(item: polisProviderConfigurationEntry)

        // 2. Create the provider directory
        polisProviderDirectory = PolisDirectory(providerDirectoryEntries: [polisProviderConfigurationEntry])
        try await flush(item: polisProviderDirectory)

        // 3. Create facility directory
        facilityDirectory = PolisObservingFacilityDirectory(lastUpdate: Date.now, observingFacilityReferences: [])
        try await flush(item: facilityDirectory)

        nc.post(name: StatusChangeNotifications.providerDidCreateNotification, object: self)
    }

    
    /// This method should be used by non data editing clients (e.g. mobile apps) trying to load the initial batch of POLIS data
    ///
    /// In client apps use this method only once. Use `cachedProvider()` in subsequent launches of the client app.
    ///
    /// - Parameter useExperimentalVersion: if `true` it tries to connect to a well known experimental test server
    func createLocalProviderByUsingExistingRemoteProvider(usingExperimentalVersion: Bool = false) async throws {
        //TODO: 0. Make sure no local data exist that could be overwritten!

        //TODO: 1. Check if the remote provider is set. If not use one of the framework provided starting "BigBang" sites

        //TODO: Implement me!
    }

    func prepareToTerminateSession() async throws {
        //TODO: Implement me!
        //TODO: Perhaps we need a delegate to complete the task> Like execute the script that Douglas is writing? The delegate
        // should have methods to sync different POLIS files one by one if they are modified.
        //TODO: N. Post ReadyToTerminate notification.
    }

    /// If there is already an existing local copy of the POLIS dataset use this method to access it
    ///
    /// - Parameter rootURL: the local file URL that lead to the path containing the `../polis` folder
    func existingLocalProvider(rootURL: URL) async throws {
        try canConfigure()
        //TODO: 0. Check for existing folders
        //TODO: 1. Check and try to load the provider configuration entry
        //TODO: 2. Check and try to load the provider directory
        //TODO: 3. Check and try to load the facility directory
        //TODO: 4. Prepare the list of all currently available observing facilities
        //TODO: 5. If needed, sync with remote providers
        //TODO: 6: Post a notification that the local copy is ready to be used
    }

    //MARK: Private stuff
    private func canConfigure() throws {
        if isConfigured { throw PolisProviderManagerError.providerAtTheSameRootPathAlreadyConfigured }
        else            { isConfigured = true }
    }
}

//MARK: - Working with Observing Facilities -
public extension PolisProviderManager {

    //TODO: Implement me!

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

    private func checkPolisDirectoryPatsExistence(paths: [String]) -> Bool {
        for path in paths {
            if (fm.fileExists(atPath: path, isDirectory: &isDir) && (isDir.boolValue)) {
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
        return checkPolisDirectoryPatsExistence(paths: polisDirectoryPaths()) && checkPolisFilesExistence(paths: essentialPolisFiles())
    }


    private func flush(item: any StorableItem) async throws {
        var currentItem: (any StorableItem)? = item

        while currentItem != nil {
            try await currentItem?.flashUsing(manager: self)
            currentItem = currentItem?.parentItem()
        }
    }
}
