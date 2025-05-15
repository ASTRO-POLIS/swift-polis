//
//  ArtifactRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation


open class ArtifactRep: PersistentAuxiliaryItem {

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var media: MediaSourceRep?
    public var website: URL?

    var mediaID: UUID?

    var facility: ObservingFacilityRep

    init(identity: PolisIdentity,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         media: MediaSourceRep?                   = nil,
         website: URL?                            = nil,
         facility: ObservingFacilityRep) {
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.media                 = media
        self.website               = website
        self.facility              = facility

        super.init(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")
    }

    //MARK: - PolisPersisting implementation -
    public func saveChanges() throws {
        if !persistenceReference.hasLocalCopy {
            nc.post(name: PolisProviderManager.StatusChangeNotification.artifactWillCreateNotification, object: nil)

            jsonData = try jsonEncoder.encode(artifact())
            if !fm.createFile(atPath: persistenceReference.localPath, contents: jsonData) {
                throw ObservingFacilityRep.ObservingFacilityRepError.cannotWritePolisFile
            }
            persistenceReference.hasLocalCopy = true

            nc.post(name: PolisProviderManager.StatusChangeNotification.artifactDidCreateNotification, object: self)
        }
        //TODO: Implement me!
    }

    public func revertToSaved() throws {
        //TODO: Implement me!
    }

    public func delete() throws {
        //TODO: Implement me!
    }

    public func loadWithID(_ id: String) throws -> any PolisPersisting {
        //TODO: Implement me!
        self
    }

    public func didChange() -> Bool {
        //TODO: Implement me!
        true
    }

    public func loadAllData() throws {
        //TODO: Implement me!
    }

    //MARK: - Private APIs -
    private func artifact() -> PolisArtifact {
        PolisArtifact(
            identity: identity,
            artifactType: artifactType,
            visitingOpportunities: visitingOpportunities,
            mediaID: mediaID,
            website: website
        )
    }
}
