//
//  Artifact.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation

public actor Artifact: @preconcurrency Persisting {

    public var identifiableObject   : IdentifiableObject
    public var artifactType         : PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var media                : MediaSource?
    public var website              : URL?

    //MARK: Non-private APIs
    var facilityID: UUID
    var mediaID   : UUID?

    public var id: UUID { identifiableObject.identity.id }

    public var lastUpdateTime: Date {
        get { identifiableObject.lastUpdateTime }
        set { identifiableObject.lastUpdateTime = newValue }
    }

    var identity: PolisIdentity {
        get { identifiableObject.identity }
        set { identifiableObject.identity  = newValue }
    }

    var artifact: PolisArtifact {
        get {
            PolisArtifact(
                identity             : identifiableObject.identity,
                facilityID           : facilityID,
                artifactType         : artifactType,
                visitingOpportunities: visitingOpportunities,
                mediaID              : mediaID,
                website              : website
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
         website: URL?                            = nil) async throws {
        self.facilityID            = await facility.id
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website

        self.identifiableObject                       = IdentifiableObject(id: identity.id, name: identity.name ?? "<unnamed>")
        self.identifiableObject.persistenceDescriptor = PersistenceDescriptor(representingStoredObjectType: .artifact, facilityID: facilityID)

        finaliseInitialisation()
    }

    init(storedArtifact: PolisArtifact, facility: ObservingFacility) async throws {
        self.artifactType                             = storedArtifact.artifactType
        self.facilityID                               = storedArtifact.facilityID

        self.identifiableObject                       = IdentifiableObject(id: storedArtifact.identity.id,
                                                                           lastUpdateTime: storedArtifact.identity.lastUpdateTime,
                                                                           name: storedArtifact.identity.name ?? "<unnamed>")
        self.identifiableObject.persistenceDescriptor = PersistenceDescriptor(representingStoredObjectType: .artifact, facilityID: storedArtifact.facilityID)

        finaliseInitialisation()
    }

    //MARK: - Private APIs -
    private var _originalArtifact: PolisArtifact!

    private func finaliseInitialisation() {
        self.identifiableObject.persistenceDescriptor?.representingStoredObjectType = .artifact
        self.identifiableObject.persistentObject.localPersistencyStatus             = .inMemoryOnly
        self.identifiableObject.persistentObject.remotePersistencyStatus            = .noRemoteRepresentation
        _originalArtifact                                                           = artifact
    }
}

//MARK: - PolisPersisting implementation -
extension Artifact {
    public func canEdit()                      async -> Bool {
        //TODO: Implement me!
        await ObjectStore.sharedObjectStore.isEditable()
    }

//    public override func startEditing()        async throws { } //TODO: Implement me!
//    public override func finishEditing()       async throws { } //TODO: Implement me!

    public func saveChanges() async throws {
        guard await didChange() else { return }
        let nc = self.identifiableObject.persistentObject.nc

        nc.post(name: AppSupportStatusChangeNotification.artifactWillSaveNotification, object: self)
        try await artifact.flashUsing(store:  ObjectStore.sharedObjectStore)
        nc.post(name: AppSupportStatusChangeNotification.artifactDidSaveNotification, object: self)
    }

    public func revertToSaved()                async throws { } //TODO: Implement me!
    public func delete()                       async throws { } //TODO: Implement me!

    public func loadData() async throws {
        let nc = self.identifiableObject.persistentObject.nc

        nc.post(name: AppSupportStatusChangeNotification.artifactWillLoadNotification, object: self)

        self.artifact = try await PolisArtifact.loadFromLocalFileSystemUsing(store     :  ObjectStore.sharedObjectStore,
                                                                             facilityID: facilityID,
                                                                             objectType: .observingFacilityDetails) as! PolisArtifact

        nc.post(name: AppSupportStatusChangeNotification.artifactDidLoadNotification, object: self)
        nc.post(name: AppSupportStatusChangeNotification.facilityDidChangeNotification, object: facilityID)
    }

    public func didChange() async -> Bool {
        (identifiableObject.persistentObject.localPersistencyStatus == .inMemoryOnly) || (_originalArtifact != artifact)
    }

    public func prepareToCloseTheObjectStore() async throws { } //TODO: Implement me!
}
