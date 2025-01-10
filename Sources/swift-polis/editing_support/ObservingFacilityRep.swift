//
//  ObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.10.24.
//

import Foundation

open class ObservingFacilityRep {

    //TODO: This needs to be part of PolisProviderManager
    public static func facility(with id: UUID) async throws -> ObservingFacilityRep? {

        //TODO: Implement me!

        return nil
    }

    // Polis Identity defined
    public let id: UUID
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
    public var facilityLocationID: UUID?                                   // Points to dictionary with some predefined (standard) keys
    public var astronomicalCode: String?                                   // Minor planet codes, etc.

    public func flush() async throws {
        let manager = PolisProviderManager.currentProviderManager!
//
//        try manager.facilityDirectory.flashUsing(manager: PolisProviderManager.currentProviderManager)
//
//        // Item
//        item.identity        = identity
//        item.owner           = owner
//        item.parentID        = parentID
//        item.media           = media
//        item.lifecycleStatus = lifecycleStatus
//
//        let facility = PolisObservingFacility(item: item, gravitationalBodyRelationship: PolisObservingFacility.ObservingFacilityLocationType.surfaceFixed, placeInTheSolarSystem: PolisObservingFacility.PlaceInTheSolarSystem.earth)
//
//        facility.gravitationalBodyRelationship            = gravitationalBodyRelationship
//        facility.placeInTheSolarSystem                    = placeInTheSolarSystem
//        facility.observingFacilityCode                    = observingFacilityCode
//        facility.solarSystemBodyName                      = solarSystemBodyName
//        facility.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
//        facility.facilityLocationID                       = facilityLocationID
//        facility.astronomicalCode                         = astronomicalCode
//
//        try await ensureFacilityFolderDoesExist()
//
//        let detailsPath = manager.polisFileResourceFinder.observingFacilityFile(observingFacilityID: identity.id)
//
//        do {
//            let data = try manager.jsonEncoder.encode(facility)
////TODO: remove later solution will be found
//            let path = "file://\(detailsPath)"
//            try data.write(to: URL(string: path.normalisedFolderPath())!)
//        }
//        catch {
//            PolisLogger.shared.error("Cannot encode or save facility details to: \(detailsPath)")
//            throw PolisProviderManager.PolisProviderManagerError.cannotWriteFile
//        }
    }

    func ensureFacilityFolderDoesExist() async throws {
//        let manager = PolisProviderManager.currentProviderManager!
//        let path    = manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: identity.id)
//
//        if !manager.tryToEnsureFoldersExistence(paths: [path]) {
//            PolisLogger.shared.error("Cannot create or access facility forlder: \(path)")
//            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
//        }
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
        self.id = id
        self.lastUpdateDate = lastUpdateDate
        self.name = name
    }
}
