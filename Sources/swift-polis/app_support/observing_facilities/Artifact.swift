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
    public var mediaID: UUID?
    public var website: URL?

    var facility: ObservingFacilityDetails

    init(identity: PolisIdentity,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         website: URL?                            = nil,
         facility: ObservingFacilityDetails) async throws {
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website
        self.facility              = facility

        try await super.init(id: identity.id, lastUpdateTime: identity.lastUpdateTime, name: identity.name ?? "<unnamed>")
    }

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

    //MARK: - Private APIs -
    var artifact: PolisArtifact {
        get {
            PolisArtifact(
                identity: identity,
                artifactType: artifactType,
                visitingOpportunities: visitingOpportunities,
                mediaID: mediaID,
                website: website
            )
        }
        set {
            identity        = newValue.identity
            artifactType   = newValue.artifactType
            visitingOpportunities = newValue.visitingOpportunities
            mediaID = newValue.mediaID

        }
    }
}
