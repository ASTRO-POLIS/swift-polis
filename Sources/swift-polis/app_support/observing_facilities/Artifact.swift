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

    var facility: ObservingFacility

    init(identity: PolisIdentity,
         artifactType: PolisArtifact.ArtifactType = .unknown,
         visitingOpportunities: String?           = nil,
         mediaID: UUID?                           = nil,
         website: URL?                            = nil,
         facility: ObservingFacility) throws {
        self.artifactType          = artifactType
        self.visitingOpportunities = visitingOpportunities
        self.mediaID               = mediaID
        self.website               = website
        self.facility              = facility

        try super.init(id: identity.id, lastUpdateTime: identity.lastUpdateTime, name: identity.name ?? "<unnamed>")
    }

    //MARK: - PolisPersisting implementation -
    public func canEdit() async -> Bool { true }

    public func saveChanges() throws {
//        if !persistenceReference.hasLocalCopy {
//            nc.post(name: AppSupportStatusChangeNotification.artifactWillCreateNotification, object: nil)
//
//            jsonData = try jsonEncoder.encode(artifact)
//            if !fm.createFile(atPath: persistenceReference.localPath, contents: jsonData) {
//                throw ObservingFacilityRep.ObservingFacilityRepError.cannotWritePolisFile
//            }
//            persistenceReference.hasLocalCopy = true
//
//            if facility.artifactIDs == nil { facility.artifactIDs = Set<UUID>() }
//            facility.artifactIDs!.insert(identity.id)
//            facility.setHasChanges()
//            try facility.saveChanges()
//
//            nc.post(name: AppSupportStatusChangeNotification.artifactDidCreateNotification, object: self)
//        }
//        else {  // Overwrite data
//            //TODO: Implement me!
//        }
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
