//
//  MediaSource.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation

open class MediaSource: IdentifiableObject {

    public var mediaItems: [PolisMediaSource.MediaItem] = []

    public var facility: ObservingFacility?
    var facilityID: UUID?

    var mediaSource: PolisMediaSource {
        get {
            PolisMediaSource(identity: identity)
        }
        set {
            identity   = newValue.identity
            mediaItems = newValue.mediaItems
        }
    }

    public init(identity: PolisIdentity,
                facility: ObservingFacility? = nil,
                name:     String) throws {

        self.facility   = facility
        self.facilityID = facility?.id

        try super.init(id: identity.id,
                       lastUpdateTime: identity.lastUpdateTime,
                       name: name,
                       facilityID: facility?.id,
                       representingStoredObjectType: .unknown)

        finaliseInitialisation()
    }

    // MARK: - Private
    private var _originalMediaSource: PolisMediaSource!

    private func finaliseInitialisation() {
        self.localPersistencyStatus  = .inMemoryOnly
        self.remotePersistencyStatus = .noRemoteRepresentation
        _originalMediaSource         = mediaSource
    }
}

public extension MediaSource {
    func addMediaItem(_ item: PolisMediaSource.MediaItem) {
        if let idx = mediaItems.firstIndex(where: { $0.id == item.id }) {
            if mediaItems[idx].lastUpdateDate < item.lastUpdateDate {
                mediaItems.remove(at: idx)
                mediaItems.append(item)
            }
            return
        }
        mediaItems.append(item)
    }

    func removeMediaItem(with id: UUID) {
        if let idx = mediaItems.firstIndex(where: { $0.id == id }) {
            mediaItems.remove(at: idx)
        }
    }
}

// MARK: - PolisPersisting implementation
extension MediaSource {
    public func canEdit() async -> Bool {
        await store.isEditable()
    }

    public func saveChanges() async throws {
        guard await didChange() else { return }
        nc.post(name: AppSupportStatusChangeNotification.mediaSourceWillSaveNotification, object: self)
        // try await mediaSource.flashUsing(store: store) // TODO: Implement me!
        nc.post(name: AppSupportStatusChangeNotification.mediaSourceDidSaveNotification, object: self)
    }

    public func revertToSaved() async throws { } // TODO: Implement me!

    public func delete() async throws { } // TODO: Implement me!

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.mediaSourceWillLoadNotification, object: self)

        self.mediaSource = try await PolisMediaSource.loadFromLocalFileSystemUsing(store: store,
                                                                              facilityID: facilityID,
                                                                              objectType: .observingFacilityDetails) as! PolisMediaSource

        nc.post(name: AppSupportStatusChangeNotification.mediaSourceDidLoadNotification, object: self)
    }

    public func didChange() async -> Bool { _originalMediaSource != mediaSource }

    public func prepareToCloseTheObjectStore() async throws { } // TODO: Implement me!
}
