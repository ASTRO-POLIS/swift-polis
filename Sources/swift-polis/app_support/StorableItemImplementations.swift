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

        data = fm.contents(atPath: path)

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
    
    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { nil }

    func flashUsing(store: ObjectStore) async throws {
        let finder      = await store.fileResourceFinder()
        let path        = finder.configurationFile()
        var newDirEntry = self

        newDirEntry.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(newDirEntry) }
        catch {
            PolisLogger.shared.error("PolisDirectory.ProviderDirectoryEntry:flashUsing - Cannot encode POLIS Provider Main Configuration Entry")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisDirectory.ProviderDirectoryEntry:flashUsing")
    }
}

//MARK: - PolisDirectory -
extension PolisDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.polisProviderDirectoryFile()

        data = fm.contents(atPath: path)


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
    
    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { await store.polisProviderConfigurationEntry() }

    func flashUsing(store: ObjectStore) async throws {
        let finder = await store.fileResourceFinder()
        let path   = finder.polisProviderDirectoryFile()
        var dir    = self

        dir.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(dir) }
        catch {
            PolisLogger.shared.error("PolisDirectory:flashUsing - Cannot encode POLIS Directory")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisDirectory:flashUsing")

        await store.setPolisProviderConfigurationEntry(store.polisProviderConfigurationEntry())
    }
}

//MARK: - PolisObservingFacilityDirectory -
extension PolisObservingFacilityDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilitiesDirectoryFile()

        data = fm.contents(atPath: path)

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


    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { await store.polisProviderConfigurationEntry() }

    func flashUsing(store: ObjectStore) async throws {
        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilitiesDirectoryFile()
        var dir    = self

        dir.lastUpdate = Date.now

        do    { data = try jsonEncoder.encode(dir) }
        catch {
            PolisLogger.shared.error("PolisObservingFacilityDirectory:flashUsing - Cannot encode POLIS Observing Facility Directory")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisObservingFacilityDirectory:flashUsing")
    }
}

//MARK: - PolisObservingFacilityDetails -
extension PolisObservingFacilityDetails: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore, facilityID: UUID? = nil, objectID: UUID? = nil, objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilityFile(observingFacilityID: facilityID)

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(PolisObservingFacilityDetails.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }
    
    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws {
        //TODO: Implement me!
    }

    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { await store.facilityDirectory() }

    func flashUsing(store: ObjectStore) async throws {
        let finder  = await store.fileResourceFinder()
        let path    = finder.observingFacilityFile(observingFacilityID: item.identity.id)
        var details = self

        details.item.identity.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(details) }
        catch {
            PolisLogger.shared.error("PolisObservingFacilityDetails:flashUsing - Cannot encode POLIS Observing Facility Details")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisObservingFacilityDetails:flashUsing")
    }
}

//MARK: - PolisArtifact -
extension PolisArtifact: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore, facilityID: UUID? = nil, objectID: UUID? = nil, objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(PolisArtifact.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }

    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws { } //TODO: Implement me!

    //FIXME: This needs rethinking!
//    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { try await store.facilityWithId(facilityID)?.facilityDetails }
    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { nil }

    func flashUsing(store: ObjectStore) async throws {
        let finder  = await store.fileResourceFinder()
        let path    = finder.observingDataFile(withID: id, observingFacilityID: facilityID)
        var details = self

        details.identity.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(details) }
        catch {
            PolisLogger.shared.error("PolisArtifact:flashUsing - Cannot encode POLIS Artifact")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisArtifact:flashUsing")
    }
}

//MARK: - PolisEarthFixedBaseObservingFacilityDetails -
extension PolisEarthFixedBaseObservingFacilityDetails: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID? = nil,
                                             objectID: UUID? = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let entry = try decoder.decode(PolisEarthFixedBaseObservingFacilityDetails.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }

    static func removeFromLocalFileSystemUsing(store: ObjectStore) async throws { } //TODO: Implement me!

    //FIXME: This needs rethinking!
//    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { try await store.facilityWithId(facilityID)?.facilityDetails }
    func parentItem(store: ObjectStore) async throws -> (any StorableItem)? { nil }

    func flashUsing(store: ObjectStore) async throws {
        let finder  = await store.fileResourceFinder()
        let path    = finder.observingDataFile(withID: id, observingFacilityID: facilityID)
        var details = self

        details.lastUpdateTime = Date.now

        do    { data = try jsonEncoder.encode(details) }
        catch {
            PolisLogger.shared.error("PolisEarthFixedBaseObservingFacilityDetails:flashUsing - Cannot encode POLIS PolisEarthFixedBaseObservingFacilityDetails")
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, caller: "PolisEarthFixedBaseObservingFacilityDetails:flashUsing")
    }
}

//MARK: File Private stuff
fileprivate let jsonEncoder = PrettyJSONEncoder()
fileprivate let jsonDecoder = PrettyJSONDecoder()
fileprivate let fm = FileManager.default
fileprivate var data: Data?

fileprivate func saveFileAt(path: String, caller: String) async throws {
    do {
        if fm.fileExists(atPath: path) { try fm.removeItem(atPath: path) }
    }
    catch {
        PolisLogger.shared.error("\(caller) - Cannot remove POLIS object file to: \(path)")
        throw ObjectStore.ObjectStoreError.fileIO
    }

    if !fm.createFile(atPath: path, contents: data) {
        PolisLogger.shared.error("\(caller) - Cannot save POLIS opject file to: \(path)")
        throw ObjectStore.ObjectStoreError.cannotWriteFile
    }

}
