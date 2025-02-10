//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep {

    // Polis Identity defined
    public let id: UUID
    public var externalReferences: [String]? { didSet { identityDidChange = true } }
    public var lastUpdateDate: Date          { didSet { identityDidChange = true } }
    public var name: String                  { didSet { identityDidChange = true } }
    public var localName: String?            { didSet { identityDidChange = true } }
    public var abbreviation: String?         { didSet { identityDidChange = true } }
    public var shortDescription: String?     { didSet { identityDidChange = true } }
    public var startDate: Date?              { didSet { identityDidChange = true } }
    public var endDate: Date?                { didSet { identityDidChange = true } }
    public var polisRegistrationDate: Date?  { didSet { identityDidChange = true } }
    private var identityDidChange: Bool = false

    // Polis Item defined
    public var owner: PolisOwner?                                                   { didSet { detailsDidChange = true } }
    public var parentID: UUID?                                                      { didSet { detailsDidChange = true } }
    public var automationLabel: String?                                             { didSet { detailsDidChange = true } }
    public var lifecycleStatus: PolisLifecycleStatus = PolisLifecycleStatus.unknown { didSet { detailsDidChange = true } }
    public var media: PolisMediaSource?                                             { didSet { detailsDidChange = true } }

    // Polis Observing Facility Details defined
    public var gravitationalBodyRelationship = PolisObservingFacility.ObservingFacilityLocationType.surfaceFixed { didSet { detailsDidChange = true } }
    public var placeInTheSolarSystem         = PolisObservingFacility.PlaceInTheSolarSystem.earth                { didSet { detailsDidChange = true } }
    public var observingFacilityCode: String?                                                                    { didSet { detailsDidChange = true } }
    public var solarSystemBodyName: String?                                                                      { didSet { detailsDidChange = true } }
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?                                                 { didSet { detailsDidChange = true } }
    // Points to dictionary with some predefined (standard) keys
    public var facilityLocationID: UUID?                                                                         { didSet { detailsDidChange = true } }
    // Minor planet codes, etc.
    public var astronomicalCode: String?                                                                         { didSet { detailsDidChange = true } }
    private var detailsDidChange: Bool = false

    public func flush() async throws {
        let provider = PolisProviderManager.currentProviderManager!

        // Identity
        if identityDidChange {
            let dirEntry = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)

            provider.facilityDirectory.addOrUpdateObservingFacility(reference: dirEntry)
            try provider.flush(item: provider.facilityDirectory)

            if detailsDidChange {
                let facilityDetails                                      = PolisObservingFacility(item: item,
                                                                                                  gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                                                  placeInTheSolarSystem: placeInTheSolarSystem)
                facilityDetails.observingFacilityCode                    = observingFacilityCode
                facilityDetails.solarSystemBodyName                      = solarSystemBodyName
                facilityDetails.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
                facilityDetails.facilityLocationID                       = facilityLocationID
                facilityDetails.astronomicalCode                         = astronomicalCode

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
        }
    }

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
    }

    init(id: UUID, lastUpdateDate: Date = Date(), name: String) {
        self.id             = id
        self.lastUpdateDate = lastUpdateDate
        self.name           = name
        manager             = PolisProviderManager.currentProviderManager!
    }

    private let manager: PolisProviderManager!
}
