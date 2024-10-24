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

    /// Semi replacement for singleton
    ///
    /// Make sure the public init() was called before trying to access this within the framework
    static var currentProviderManager: PolisProviderManager!

    //MARK: Polis Provider Manager internal configuration
    let polisImplementation: PolisImplementation!
    let polisFileResourceFinder: PolisFileResourceFinder!

    var polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!
    var polisProviderDirectory: PolisDirectory!
    var facilityDirectory: PolisObservingFacilityDirectory!

    /// Designate initialiser
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    public init() throws {
        guard PolisProviderManager.currentProviderManager == nil else { throw PolisProviderManagerError.cannotRegisterMultipleManagerInstances }

        self.polisImplementation     = PolisConstants.frameworkSupportedImplementation.last
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

    private var jsonEncoder     = PrettyJSONEncoder()
    private var jsonDecoder     = PrettyJSONDecoder()

    private var isConfigured    = false // check if any of the configuration methods was called

}

//MARK: - Configuration of the POLIS Service Provider -
public extension PolisProviderManager {

    /// Creates a new provider based on the content of the `configuration`
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
                                                                  adminContact: admin)

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

    func localProvider(using providerUrl: URL, isMirror: Bool = false) async throws {
        try canConfigure()
        //TODO: Implement me!
    }

    func cachedProvider() async throws {
        try canConfigure()
        //TODO: Implement me!
    }

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

    //TODO: Move these methods to SoftwareEtudes
    private func tryToEnsureFoldersExistence(paths: [String]) -> Bool {
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

    private func tryToEnsureFileExistence(paths: [String], createEmptyFilesIfDoNotExist: Bool = false) -> Bool {
        //TODO: Implement me!
        return true
    }

    private func ensurePolisFoldersExistence()  -> Bool {
        let paths = [polisFileResourceFinder.baseFolder(),                 // ../polis/
                     polisFileResourceFinder.observingFacilitiesFolder(),  // ../polis/<version>/polis_observing_facilities/
                     polisFileResourceFinder.resourcesFolder(),            // ../polis/<version>/polis_resources/
                     polisFileResourceFinder.ownersFolder(),               // ../polis/<version>/polis_owners/
                     polisFileResourceFinder.manufacturersFolder()         // ../polis/<version>/polis_manufacturers/
        ]
        return tryToEnsureFoldersExistence(paths: paths)
    }

    private func flush(item: any StorableItem) async throws {
        var currentItem: (any StorableItem)? = item

        while currentItem != nil {
            try await currentItem?.flashUsing(manager: self)
            currentItem = currentItem?.parentItem()
        }
    }
}
