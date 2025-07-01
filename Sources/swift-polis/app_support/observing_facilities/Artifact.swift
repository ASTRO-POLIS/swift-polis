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

    public var facility: ObservingFacilityDetails!

    //MARK: - PolisPersisting implementation -
    public func canEdit()                      async -> Bool {
        //TODO: Implement me!
        await store.isEditable()
    }

    public override func startEditing()        async throws { } //TODO: Implement me!
    public override func finishEditing()       async throws { } //TODO: Implement me!

    public func saveChanges()                  async throws { } //TODO: Implement me!
    public func revertToSaved()                async throws { } //TODO: Implement me!
    public func delete()                       async throws { } //TODO: Implement me!
    public func loadData()                     async throws { } //TODO: Implement me!

    public func didChange()                    async -> Bool { false } //TODO: Implement me!

    public func prepareToCloseTheObjectStore() async throws { } //TODO: Implement me!

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
         facilityID: UUID,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         website: URL?                            = nil) async throws {
        self.facilityID            = facilityID
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website
        
        try await super.init(id: identity.id,
                             lastUpdateTime: identity.lastUpdateTime,
                             name: identity.name ?? "<unnamed>",
                             facilityID : facilityID,
                             representingStoredObjectType: .artifact)
    }
}

