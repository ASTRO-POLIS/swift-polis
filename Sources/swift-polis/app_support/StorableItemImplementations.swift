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
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisDirectory.ProviderDirectoryEntry.self, from: data)

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
        var data: Data

        newDirEntry.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(newDirEntry) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisDirectory.ProviderDirectoryEntry:flashUsing - Cannot encode POLIS Provider Main Configuration Entry") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisDirectory.ProviderDirectoryEntry:flashUsing")
    }
}

//MARK: - PolisDirectory -
extension PolisDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.polisProviderDirectoryFile()
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)


        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisDirectory.self, from: data)

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
        var data: Data

        dir.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(dir) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisDirectory:flashUsing - Cannot encode POLIS Directory") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisDirectory:flashUsing")

        await store.setPolisProviderConfigurationEntry(store.polisProviderConfigurationEntry())
    }
}

//MARK: - PolisObservingFacilityDirectory -
extension PolisObservingFacilityDirectory: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore) async throws -> AnyObject {
        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilitiesDirectoryFile()
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisObservingFacilityDirectory.self, from: data)

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
        var data: Data

        dir.lastUpdate = Date.now

        do    { data = try __localResources.jsonEncoder.encode(dir) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisObservingFacilityDirectory:flashUsing - Cannot encode POLIS Observing Facility Directory") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisObservingFacilityDirectory:flashUsing")
    }
}

//MARK: - PolisObservingFacilityDetails -
extension PolisObservingFacilityDetails: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID?                         = nil,
                                             objectID: UUID?                           = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingFacilityFile(observingFacilityID: facilityID)
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisObservingFacilityDetails.self, from: data)

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
        var data: Data

        details.item.identity.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(details) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisObservingFacilityDetails:flashUsing - Cannot encode POLIS Observing Facility Details") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisObservingFacilityDetails:flashUsing")
    }
}

//MARK: - PolisArtifact -
extension PolisArtifact: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID?                         = nil,
                                             objectID: UUID?                           = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisArtifact.self, from: data)

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
        var data: Data

        details.identity.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(details) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisArtifact:flashUsing - Cannot encode POLIS Artifact") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisArtifact:flashUsing")
    }
}

//MARK: - PolisEarthFixedBaseObservingFacilityDetails -
extension PolisEarthFixedBaseObservingFacilityDetails: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID?                         = nil,
                                             objectID: UUID?                           = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisEarthFixedBaseObservingFacilityDetails.self, from: data)

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
        var data: Data

        details.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(details) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisEarthFixedBaseObservingFacilityDetails:flashUsing - Cannot encode POLIS PolisEarthFixedBaseObservingFacilityDetails") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisEarthFixedBaseObservingFacilityDetails:flashUsing")
    }
}

//MARK: - PolisPlace -
extension PolisPlace: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID?                         = nil,
                                             objectID: UUID?                           = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisPlace.self, from: data)

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
        var data: Data

        details.lastUpdateTime = Date.now

        do    { data = try __localResources.jsonEncoder.encode(details) }
        catch {
            await MainActor.run { PolisLogger.shared.error("PolisPlace:flashUsing - Cannot encode POLIS PolisPlace") }
            throw ObjectStore.ObjectStoreError.cannotEncodePolisType
        }

        try await saveFileAt(path:path, data: data, caller: "PolisPlace:flashUsing")
    }
}

//MARK: - PolisMediaSource -
extension PolisMediaSource: StorableItem {
    static func loadFromLocalFileSystemUsing(store: ObjectStore,
                                             facilityID: UUID?                         = nil,
                                             objectID: UUID?                           = nil,
                                             objectType: RepresentingStoredObjectType? = nil) async throws -> AnyObject {
        guard let facilityID = facilityID else { throw ObjectStore.ObjectStoreError.missingRequiredID }
        guard let objectID   = objectID   else { throw ObjectStore.ObjectStoreError.missingRequiredID }

        let finder = await store.fileResourceFinder()
        let path   = finder.observingDataFile(withID: objectID, observingFacilityID: facilityID)
        let fm     = FileManager.default
        var data: Data?

        data = fm.contents(atPath: path)

        guard let data = data else { throw ObjectStore.ObjectStoreError.cannotAccessOrCreateStandardPolisFile }

        do {
            let entry = try __localResources.jsonDecoder.decode(PolisMediaSource.self, from: data)

            return entry as AnyObject
        }
        catch { throw ObjectStore.ObjectStoreError.cannotDecodePolisType }
    }
}

//MARK: File Private stuff
//fileprivate let jsonEncoder = PrettyJSONEncoder()
//fileprivate let jsonDecoder = PrettyJSONDecoder()
//fileprivate let fm          = FileManager.default
//fileprivate var data: Data?

fileprivate func saveFileAt(path: String, data: Data, caller: String) async throws {
    let fm = FileManager.default

    do {
        if fm.fileExists(atPath: path) { try fm.removeItem(atPath: path) }
    }
    catch {
        await MainActor.run { PolisLogger.shared.error("\(caller) - Cannot remove POLIS object file to: \(path)") }
        throw ObjectStore.ObjectStoreError.fileIO
    }

    if !fm.createFile(atPath: path, contents: data) {
        await MainActor.run { PolisLogger.shared.error("\(caller) - Cannot save POLIS object file to: \(path)") }
        throw ObjectStore.ObjectStoreError.cannotWriteFile
    }

}
