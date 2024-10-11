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
    public let reachability = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public let name: String
    public let shortDescription: String?
    public let url: String?
    public let supportedImplementations: [PolisImplementation]
    public let providerType = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental

    public let adminName: String
    public let adminEmail: String
    public let adminNote: String?
}

public final class PolisProviderManager {

    //MARK: Notifications
    public struct StatusChangeNotifications {
        public static let providerWillCreateNotification = Notification.Name("providerWillCreate")
        public static let providerDidCreateNotification  = Notification.Name("providerWDidCreate")
    }

    //MARK: Error definitions
    public enum PolisProviderManagerError: Error {
        case cannotAccessOrCreateStandardPolisFolder
        case providerAtTheSameRootPathAlreadyConfigured // Thrown by attempting to call multiple configuration methods
        case cannotEncodePolisType                      // JSON encoding
        case cannotWriteFile
    }

    /// `localPolisRootPath` is the root path of the locally created POLIS provider.
    ///
    /// `localPolisRootPath` must be set before any other factory method is called.
    public static var localPolisRootPath: String = "/tmp/"

    //MARK: Polis Provider Manager internal configuration
    let polisImplementation: PolisImplementation!
    let polisFileResourceFinder: PolisFileResourceFinder!

    var polisProviderConfigurationEntry: PolisDirectory.ProviderDirectoryEntry!


    /// Designate initialiser
    ///
    ///  Before calling, make sure that `localPolisRootPath` is set to proper existing path
    public init() async throws {
        self.polisImplementation     = PolisConstants.frameworkSupportedImplementation.last
        self.polisFileResourceFinder = try PolisFileResourceFinder(at: URL(fileURLWithPath: PolisProviderManager.localPolisRootPath), supportedImplementation: self.polisImplementation)

        if !ensurePolisFoldersExistence() { throw PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder }
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

//MARK: - Configuration of the POLIS Service Provider
public extension PolisProviderManager {

    /// Creates a new provider based on the content of the `configuration`
    ///
    /// - Parameter configuration: contains all information needed to create a new POLIS provider
    /// - Returns: an instance of `PolisProviderManager`
    func createLocalProvider(configuration: PolisProviderConfiguration) async throws {
        try canConfigure()

        //TODO: Throw if something exists (Hasmik's suggestion)

        let admin     = PolisPerson(name: configuration.adminName, email: configuration.adminEmail, note: configuration.adminNote)
        let directory = try PolisDirectory.ProviderDirectoryEntry(name: configuration.name, supportedImplementations: configuration.supportedImplementations, providerType: configuration.providerType, adminContact: admin)

        // 1. Create the provider configuration entry
        polisProviderConfigurationEntry = directory
        try await flush(item: polisProviderConfigurationEntry)

        // 2. Create the provider directory

        // 3. Create facility directory

        //TODO: Implement me!
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

//MARK: - Working with files and folders -
extension PolisProviderManager {
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
