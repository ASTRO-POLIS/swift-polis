//
//  MediaSource.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14/06/2026.
//

import Foundation

@Observable open class MediaSource: PersistentObject, Identifiable, Hashable, @unchecked Sendable {

    public private(set) var id: UUID
    public internal(set) var lastUpdateTime: Date
    public internal(set) var facilityID: UUID // We need this because we need to know where to store the JSON file

    public var mediaItems = [PolisMediaSource.MediaItem]()

    //MARK: Make the class Hashable
    public static func == (lhs: MediaSource, rhs: MediaSource) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public override func markAsChanged() async throws { await setDidChange() }

    init(id: UUID, lastUpdateTime: Date, facilityID: UUID, mediaItems: [PolisMediaSource.MediaItem] = [PolisMediaSource.MediaItem]()) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisMediaSource(facilityID: facilityID)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: facilityID),
                                                                 objectType: .placeOnEarth)

        self.id = id
        self.lastUpdateTime = lastUpdateTime
        self.facilityID = facilityID
        self.mediaItems = mediaItems

        await super.init(polisRep: sP)
    }
    
    var mediaSource: PolisMediaSource {
        PolisMediaSource(id: id, lastUpdateTime: lastUpdateTime, facilityID: facilityID, mediaItems: mediaItems)
    }
    //MARK: - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }


    override func setDidChange() async {
        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(mediaSource)

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .placeOnEarth)
    }

}
