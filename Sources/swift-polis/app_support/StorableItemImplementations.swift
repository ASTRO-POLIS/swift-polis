//
//  StorableItemImplementations.swift
//  swift-polis
//
//  Created by Georg Tuparev on 10/06/2025.
//

import Foundation
import SoftwareEtudesUtilities

//MARK: - PolisDirectory.ProviderDirectoryEntry -
extension PolisDirectory.ProviderDirectoryEntry: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.configurationFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }

    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws {
        //TODO: Implement me!
    }
    
    func parentItem(store: ObjectStore) async -> (any StorableItem)? { nil }

    mutating func flashUsing(store: ObjectStore) async throws {
        let finder = await store.fileResourceFinder()
        let path   = finder.configurationFile()

        self.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Provider Main Configuration Entry")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Provider Main Configuration Entry to: \(path)")
            throw ObjectStore.ObjectStoreError.cannotWriteFile
        }
    }
}

//MARK: - PolisDirectory -
extension PolisDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.polisProviderDirectoryFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(PolisDirectory.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }
    
    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws {
        //TODO: Implement me!
   }
    
    func parentItem(store: ObjectStore) async -> (any StorableItem)? { await store.polisProviderConfigurationEntry() }

    mutating func flashUsing(store: ObjectStore) async throws {
        let finder = await store.fileResourceFinder()
        let path   = finder.polisProviderDirectoryFile()

        self.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Directory")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Directory to: \(path)")
            throw ObjectStore.ObjectStoreError.cannotWriteFile
        }

        await store.setPolisProviderConfigurationEntry(store.polisProviderConfigurationEntry())
    }
}

//MARK: - PolisObservingFacilityDirectory -
extension PolisObservingFacilityDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilitiesDirectoryFile()
        let fm     = FileManager.default
        let data   = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(PolisObservingFacilityDirectory.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }

    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws {
        //TODO: Implement me!
    }


    func parentItem(store: ObjectStore) async -> (any StorableItem)? { await store.polisProviderConfigurationEntry() }

    mutating func flashUsing(store: ObjectStore) async throws {
        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilitiesDirectoryFile()

        self.lastUpdate = Date.now

        do    { data = try jsonEncoder.encode(self) }
        catch {
            PolisLogger.shared.error("Cannot encode POLIS Observing Facility Directory")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        if !fm.createFile(atPath: path, contents: data) {
            PolisLogger.shared.error("Cannot save POLIS Observing Facility Directory to: \(path)")
            throw ObjectStore.ObjectStoreError.cannotWriteFile
        }

        await store.setPolisProviderConfigurationEntry(store.polisProviderConfigurationEntry())
    }
}

//MARK: File Private stuff
fileprivate let jsonEncoder = PrettyJSONEncoder()
fileprivate let jsonDecoder = PrettyJSONDecoder()
fileprivate let fm = FileManager.default
fileprivate var data: Data?
