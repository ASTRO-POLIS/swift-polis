//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep: PersistentItem {

    // Polis Identity defined
    public var id: UUID
    public var externalReferences: [String]?
    public var lastUpdateDate: Date
    public var name: String
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startDate: Date?
    public var endDate: Date?
    public var polisRegistrationDate: Date?

    // Polis Item defined
    public var owner: PolisOwner?
    public var parentID: UUID?
    public var automationLabel: String?
    public var lifecycleStatus: PolisLifecycleStatus = PolisLifecycleStatus.unknown
    public var media: PolisMediaSource?

    // Polis Observing Facility Details defined
    public var gravitationalBodyRelationship = PolisObservingFacility.ObservingFacilityLocationType.surfaceFixed
    public var placeInTheSolarSystem         = PolisObservingFacility.PlaceInTheSolarSystem.earth
    public var observingFacilityCode: String?
    public var solarSystemBodyName: String?
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?

    // Points to dictionary with some predefined (standard) keys
    public var facilityLocationID: UUID?

    // Minor planet codes, etc.
    public var astronomicalCode: String?

    /// This is used to update the in memory objects and (possibly) POLIS related files in the local file system.
    ///
    /// To reflect the changes to the local copy of  POLIS files, use ``StorableItem``'s `flashUsing(manager: )` method.
    public func flush() async throws {
        let provider = PolisProviderManager.currentProviderManager!

        // Identity
        let dirEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)

        provider.facilityDirectory.addOrUpdateObservingFacility(reference: dirEntry)
        try provider.flush(item: provider.facilityDirectory)

        // Details
        let facilityDetails                                      = PolisObservingFacility(item: item,
                                                                                          gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                                          placeInTheSolarSystem: placeInTheSolarSystem)
        facilityDetails.observingFacilityCode                    = observingFacilityCode
        facilityDetails.solarSystemBodyName                      = solarSystemBodyName
        facilityDetails.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
        facilityDetails.facilityLocationID                       = facilityLocationID
        facilityDetails.astronomicalCode                         = astronomicalCode

        //TODO: This should be rewritten when the PolisFacility implements StorableItem
        try await ensureFacilityFolderDoesExist()

        let detailsPath = manager.polisFileResourceFinder.observingFacilityFile(observingFacilityID: identity.id)

        do {
            let data = try manager.jsonEncoder.encode(facilityDetails)
            //TODO: remove later solution will be found
            let path = "file://\(detailsPath)"
            try data.write(to: URL(string: path.normalisedFolderPath())!)
        }
        catch {
            PolisLogger.shared.error("Cannot encode or save facility details to: \(detailsPath)")
            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
        }
    }

    //TODO: Move to the Polis type!
    func ensureFacilityFolderDoesExist() async throws {
        let path = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)

        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
            PolisLogger.shared.error("Cannot create or access facility forlder: \(path)")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }

    var identity: PolisIdentity {
        get {
            PolisIdentity(id: id,
                          externalReferences: externalReferences,
                          lastUpdateDate: lastUpdateDate,
                          name: name,
                          localName: localName,
                          abbreviation: abbreviation,
                          shortDescription: shortDescription,
                          startDate: startDate,
                          endDate: endDate,
                          polisRegistrationDate: polisRegistrationDate)
        }
        set {
            id                 = newValue.id
            externalReferences = newValue.externalReferences
            lastUpdateDate     = newValue.lastUpdateDate
            name               = newValue.name
            localName          = newValue.localName
            abbreviation       = newValue.abbreviation
            shortDescription   = newValue.shortDescription
            startDate          = newValue.startDate
            endDate            = newValue.endDate
        }
    }

    var item: PolisItem {
        get {
            PolisItem(identity: identity,
                      owner: owner,
                      parentID: parentID,
                      automationLabel: automationLabel,
                      lifecycleStatus: lifecycleStatus,
                      media: media)
        }
        set {
            identity         = newValue.identity
            owner            = newValue.owner
            parentID         = newValue.parentID
            automationLabel  = newValue.automationLabel
            lifecycleStatus  = newValue.lifecycleStatus
            media            = newValue.media
       }
    }

    init(id: UUID, lastUpdateDate: Date = Date(), name: String) {
        self.id             = id
        self.lastUpdateDate = lastUpdateDate
        self.name           = name
        manager             = PolisProviderManager.currentProviderManager!
    }

    //MARK: - Private properties -
    private let manager: PolisProviderManager!

    //MARK: - PolisPersisting implementation -
    public override func saveChanges() throws {
        //TODO: Implement me!

        // 1. Check if I exist as POLIS file, and if not, create myself

        // 2. Check if I did changed

        // 3. If I changed,
        // 3.1. Update PolisObservingFacility file
        // 3.2. Update the POLIS cache in Provider Manager
        // 3.3. Update the provider directory cache in Provider Manager
    }

    public override func revertToSaved() throws {
        //TODO: Implement me!
    }

    public override func delete() throws {
        //TODO: Implement me!
    }

    public override func didChange() -> Bool {
        //TODO: Implement me!
        false
    }
}

