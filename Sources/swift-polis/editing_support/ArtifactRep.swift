//
//  ArtifactRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation


open class ArtifactRep: SimplePersistentItem {

    public var artifactType: PolisArtifact.ArtifactType
    public var visitingOpportunities: String?
    public var mediaID: UUID?
    public var website: URL?

    var facility: ObservingFacilityRep

    init(identity: PolisIdentity,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         website: URL?                            = nil,
         facility: ObservingFacilityRep) throws {
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website
        self.facility              = facility

        try super.init(id: identity.id, lastUpdateDate: identity.lastUpdateDate, name: identity.name ?? "<unnamed>")
    }

    //MARK: - PolisPersisting implementation -
    public func canEdit() -> Bool { true }

    public func saveChanges() throws {
        if !persistenceReference.hasLocalCopy {
            nc.post(name: PolisProviderManager.StatusChangeNotification.artifactWillCreateNotification, object: nil)

            jsonData = try jsonEncoder.encode(artifact)
            if !fm.createFile(atPath: persistenceReference.localPath, contents: jsonData) {
                throw ObservingFacilityRep.ObservingFacilityRepError.cannotWritePolisFile
            }
            persistenceReference.hasLocalCopy = true

            if facility.artifactIDs == nil { facility.artifactIDs = Set<UUID>() }
            facility.artifactIDs!.insert(identity.id)
            facility.setHasChanges()
            try facility.saveChanges()

            nc.post(name: PolisProviderManager.StatusChangeNotification.artifactDidCreateNotification, object: self)
        }
    }

    public func revertToSaved() throws {
        //TODO: Implement me!
    }

    public func delete() throws {
        //TODO: Implement me!
    }

    public func loadData() throws { }

    public func didChange() -> Bool {
        //TODO: Implement me!
        true
    }

    public func setHasChanges(_ hasChanges: Bool = true) { }

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
