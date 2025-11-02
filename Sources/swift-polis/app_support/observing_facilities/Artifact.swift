//
//  ArtifactRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation


open class Artifact: IdentifiableObject {

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var media: MediaSource?
    public var website: URL?

    public var facility: ObservingFacility!

    //MARK: Non-private APIs
    var facilityID: UUID
    var mediaID: UUID?

    var artifact: PolisArtifact {
        get {
            PolisArtifact(
                identity: identity,
                facilityID: facilityID,
                artifactType: artifactType,
                visitingOpportunities: visitingOpportunities,
                mediaID: mediaID,
                website: website
            )
        }
        set {
            identity              = newValue.identity
            facilityID            = newValue.facilityID
            artifactType          = newValue.artifactType
            visitingOpportunities = newValue.visitingOpportunities
            mediaID               = newValue.mediaID
            website               = newValue.website
        }
    }

    init(identity: PolisIdentity,
         facility: ObservingFacility,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         website: URL?                            = nil) throws {
        self.facilityID            = facility.id
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website
        self.facility              = facility

        try super.init(id: identity.id,
                             lastUpdateTime: identity.lastUpdateTime,
                             name: identity.name ?? "<unnamed>",
                             facilityID : facilityID,
                             representingStoredObjectType: .artifact)

        finaliseInitialisation()
    }

    init(storedArtifact: PolisArtifact, facility: ObservingFacility) throws {
        self.artifactType = storedArtifact.artifactType
        self.facilityID   = storedArtifact.facilityID
        self.facility     = facility

        try super.init(id: storedArtifact.identity.id,
                             lastUpdateTime: storedArtifact.identity.lastUpdateTime,
                             name: storedArtifact.identity.name ?? "<unnamed>",
                             facilityID : storedArtifact.facilityID,
                             representingStoredObjectType: .artifact)

        finaliseInitialisation()
    }

    //MARK: - Private APIs -
    private var _originalArtifact: PolisArtifact!

    private func finaliseInitialisation() {
        self.representingStoredObjectType = .artifact
        self.localPersistencyStatus       = .inMemoryOnly
        self.remotePersistencyStatus      = .noRemoteRepresentation
        _originalArtifact                 = artifact
    }
}

//MARK: - PolisPersisting implementation -
extension Artifact {
    public func canEdit()                      async -> Bool {
        //TODO: Implement me!
        await sharedObjectStore.isEditable()
    }

//    public override func startEditing()        async throws { } //TODO: Implement me!
//    public override func finishEditing()       async throws { } //TODO: Implement me!

    public func saveChanges() async throws {
        guard await didChange() else { return }

        nc.post(name: AppSupportStatusChangeNotification.artifactWillSaveNotification, object: self)
        try await artifact.flashUsing(store: sharedObjectStore)
        nc.post(name: AppSupportStatusChangeNotification.artifactDidSaveNotification, object: self)
    }

    public func revertToSaved()                async throws { } //TODO: Implement me!
    public func delete()                       async throws { } //TODO: Implement me!

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.artifactWillLoadNotification, object: self)

        self.artifact = try await PolisArtifact.loadFromLocalFileSystemUsing(store: sharedObjectStore,
                                                                             facilityID: facilityID,
                                                                             objectType: .observingFacilityDetails) as! PolisArtifact

        nc.post(name: AppSupportStatusChangeNotification.artifactDidLoadNotification, object: self)
        nc.post(name: AppSupportStatusChangeNotification.facilityDidChangeNotification, object: facility)
    }

    public func didChange() async -> Bool {
        (localPersistencyStatus == .inMemoryOnly) || (_originalArtifact != artifact)
    }

    public func prepareToCloseTheObjectStore() async throws { } //TODO: Implement me!


}
