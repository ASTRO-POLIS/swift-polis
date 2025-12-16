//
//  MediaSource.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation

public actor MediaSource: @preconcurrency Persisting, Sendable {

    public var identifiableObject: IdentifiableObject
    public var id                : UUID { identifiableObject.identity.id }
    public var mediaItems        : [PolisMediaSource.MediaItem] = []

    var facilityID: UUID?

    var identity: PolisIdentity {
        get { identifiableObject.identity }
        set { identifiableObject.identity  = newValue }
    }

    var mediaSource: PolisMediaSource {
        get {
            PolisMediaSource(identity: identity)
        }
        set {
            identity   = newValue.identity
            mediaItems = newValue.mediaItems
        }
    }

    public init(identity: PolisIdentity, facilityID: UUID, name: String) async throws {
        self.facilityID                               = facilityID
        self.identifiableObject                       = IdentifiableObject(id: identity.id, lastUpdateTime: identity.lastUpdateTime, name: name)
        self.identifiableObject.persistenceDescriptor = PersistenceDescriptor(representingStoredObjectType: .unknown, facilityID: facilityID)

        await finaliseInitialisation()
    }

    // MARK: - Private
    private var _originalMediaSource: PolisMediaSource!

    private func finaliseInitialisation() async {
        self.identifiableObject.persistentObject.localPersistencyStatus  = .inMemoryOnly
        self.identifiableObject.persistentObject.remotePersistencyStatus = .noRemoteRepresentation
        _originalMediaSource                                             = mediaSource
    }
}

public extension MediaSource {
    func addMediaItem(_ item: PolisMediaSource.MediaItem) {
        if let idx = mediaItems.firstIndex(where: { $0.id == item.id }) {
            if mediaItems[idx].lastUpdateTime < item.lastUpdateTime {
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
        await ObjectStore.sharedObjectStore.isEditable()
    }

    public func saveChanges() async throws {
        guard await didChange() else { return }
        let nc = self.identifiableObject.persistentObject.nc

        nc.post(name: AppSupportStatusChangeNotification.mediaSourceWillSaveNotification, object: self)
        // try await mediaSource.flashUsing(store: store) // TODO: Implement me!
        nc.post(name: AppSupportStatusChangeNotification.mediaSourceDidSaveNotification, object: self)
    }

    public func revertToSaved() async throws { } // TODO: Implement me!

    public func delete() async throws { } // TODO: Implement me!

    public func loadData() async throws {
        let nc = self.identifiableObject.persistentObject.nc

        nc.post(name: AppSupportStatusChangeNotification.mediaSourceWillLoadNotification, object: self)

        self.mediaSource = try await PolisMediaSource.loadFromLocalFileSystemUsing(store: ObjectStore.sharedObjectStore,
                                                                              facilityID: facilityID,
                                                                              objectType: .observingFacilityDetails) as! PolisMediaSource

        nc.post(name: AppSupportStatusChangeNotification.mediaSourceDidLoadNotification, object: self)
    }

    public func didChange() async -> Bool { _originalMediaSource != mediaSource }

    public func prepareToCloseTheObjectStore() async throws { } // TODO: Implement me!
}
