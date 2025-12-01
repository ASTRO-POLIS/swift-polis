//
//  ObjectStoreConfiguration.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/06/2025.
//

import Foundation

@MainActor
public final class ObjectStoreConfiguration {

    public static let shared = ObjectStoreConfiguration()

    /// The (latest) version that will be used to sync working copy of the data for read access and editing
    ///
    /// Later implementations might sync also other (older) versions, but this is not required. Default implementation will use the newest possible software version.
    public static var latestWorkingPolisVersion = polisFrameworkSupportedImplementation.last

    public enum ConfigurationError: Error {
        case objectStoreConfigurationNotCompleted // ... in case required setters are not called
        case rootFolderNotSet
        case rootFolderNotAccessible
        case remoteDomainNotValidURL
        case cannotCreateObjectStore
    }

    //MARK:  Configuration APIs
    /// Sets the root folder for all POLIS data
    ///
    /// The folder must be readable and writable. If inaccessible `rootFolderNotAccessible` will be thrown.
    /// - Parameter localPolisRootFolder: full path to the root folder
    public func setLocalPolisRootFolder(_ localPolisRootFolder: String) throws {
        if !(fm.fileExists(atPath: localPolisRootFolder, isDirectory: &isDir) && (isDir.boolValue)) {
            logger.warning("ObjectStoreConfiguration:setLocalPolisRootFolder - Root folder \(localPolisRootFolder) does not exist or is not a directory")
            throw ConfigurationError.rootFolderNotAccessible
        }

        if _localPolisRootFolder != localPolisRootFolder {
            _configurationDidChange = true
            _fileResourceFinder     = nil
            _localPolisRootFolder   = localPolisRootFolder
        }
    }
    
    /// Sets the remote Service Provider domain used to sync the static data
    ///
    ///  **Note:** The default value is set to `https://polis.observer`. This domain is guaranteed to exist.
    /// - Parameter remoteDomain: fully qualified URL
    public func setRemoteDomain(_ remoteDomain: String) throws {
        guard URL(string: remoteDomain) == nil else {
            logger.warning("ObjectStoreConfiguration:setRemoteDomain - Remote domain \(remoteDomain) is not a valid URL")
            throw ConfigurationError.remoteDomainNotValidURL
        }

        if _remoteDomain != remoteDomain {
            _configurationDidChange = true
            _remoteResourceFinder   = nil
            _remoteDomain           = remoteDomain
        }
    }

    // Working with Object Store
    public func objectStore() async throws -> ObjectStore {
        guard isFullyConfigured() else {
            logger.error("ObjectStoreConfiguration:objectStore - Configuration not completed")
            throw ConfigurationError.objectStoreConfigurationNotCompleted
        }

        let needNewInstance = _configurationDidChange || _objectStore == nil

        if needNewInstance {
            if _objectStore != nil {
                Task {
                    try await _objectStore!.close()
                }
            }

            let polisImplementation = ObjectStoreConfiguration.latestWorkingPolisVersion

            if let url = URL(string: _localPolisRootFolder!) {
                _fileResourceFinder = try PolisFileResourceFinder(at: url, supportedImplementation: polisImplementation!)
            }
            else {
                logger.error("ObjectStoreConfiguration:objectStore - Cannot create URL from root folder: \(_localPolisRootFolder!)")
                throw ConfigurationError.cannotCreateObjectStore
            }

            if let remoteURL = URL(string: _remoteDomain) {
                try _remoteResourceFinder = PolisRemoteResourceFinder(at: remoteURL, supportedImplementation: polisFrameworkSupportedImplementation.last!)
            }
            else {
                logger.error("ObjectStoreConfiguration:objectStore - Cannot create URL from remote service provider: \(_remoteDomain)")
                throw ConfigurationError.cannotCreateObjectStore
            }

            _objectStore = await ObjectStore(fileResourceFinder: _fileResourceFinder!, remoteResourceFinder: _remoteResourceFinder!)
        }
        return _objectStore!
    }

    //MARK: Not-public APIs
    static let testingFolder = "/Users/Shared/Work/polis_tests"

    //MARK: Private APIs
    private var _configurationDidChange = true
    private var _objectStore          : ObjectStore?
    private var _localPolisRootFolder : String?
    private var _remoteDomain           = PolisConstants.bigBangPolisDomain

    private var _fileResourceFinder: PolisFileResourceFinder?
    private var _remoteResourceFinder: PolisRemoteResourceFinder?

    private let logger          = SEPolisLogger.logger("ObjectStoreConfiguration")
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false

    private func isFullyConfigured() -> Bool { _localPolisRootFolder != nil }
}
