//
//  PolisObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacility: Identifiable, Codable, StorableItem, Equatable {

    // Identification and type
    public var item: PolisItem
    public var gravitationalBodyRelationship: PolisObservingFacilityLocationType
    public var placeInTheSolarSystem: PolisPlaceInTheSolarSystem
    public var observingFacilityCode: String?

    // Where in the Solar system
    public var solarSystemBodyName: String?
    public var orbitingAroundPlaceInTheSolarSystemNamed: String?
    public var facilityLocationID: UUID?                                   // Points to dictionary with some predefined (standard) keys
    public var astronomicalCode: String?                                   // Minor planet codes, etc.

    // Relationship to other facilities
    public var parentObservingFacilityID: UUID?

    // Contains
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

    // Info
    public var website: URL?
    public var scientificObjectives: String?
    public var history: String?

    // Facility details UUIDs - one and only one type could be assigned!
    public var fixedSurfaceEarthBaseDetailsID: UUID?
    public var mobileSurfaceEarthBaseDetailsID: UUID?
    public var airborneEarthBaseDetailsID: UUID?

    // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)
    public var artifactIDs: Set<UUID>?

    //TODO: ... and satellites, rovers, ... to be added

    // Identifiable protocol compliance
    public var id: UUID { item.identity.id }


    public init(item: PolisItem,
                gravitationalBodyRelationship: PolisObservingFacilityLocationType,
                placeInTheSolarSystem: PolisPlaceInTheSolarSystem,
                observingFacilityCode: String?                    = nil,
                solarSystemBodyName: String?                      = nil,
                orbitingAroundPlaceInTheSolarSystemNamed: String? = nil,
                facilityLocationID: UUID?                         = nil,
                astronomicalCode: String?                         = nil,
                parentObservingFacilityID: UUID?                  = nil,
                observatoryIDs: Set<UUID>?                        = nil,
                deviceIDs: Set<UUID>?                             = nil,
                website: URL?                                     = nil,
                scientificObjectives: String?                     = nil,
                history: String?                                  = nil,
                fixedSurfaceEarthBaseDetailsID: UUID?             = nil,
                mobileSurfaceEarthBaseDetailsID: UUID?            = nil,
                airborneEarthBaseDetailsID: UUID?                 = nil) {
        self.item                                     = item
        self.gravitationalBodyRelationship            = gravitationalBodyRelationship
        self.placeInTheSolarSystem                    = placeInTheSolarSystem
        self.observingFacilityCode                    = observingFacilityCode
        self.solarSystemBodyName                      = solarSystemBodyName
        self.orbitingAroundPlaceInTheSolarSystemNamed = orbitingAroundPlaceInTheSolarSystemNamed
        self.facilityLocationID                       = facilityLocationID
        self.astronomicalCode                         = astronomicalCode
        self.parentObservingFacilityID                = parentObservingFacilityID
        self.observatoryIDs                           = observatoryIDs
        self.deviceIDs                                = deviceIDs
        self.website                                  = website
        self.scientificObjectives                     = scientificObjectives
        self.history                                  = history
        self.fixedSurfaceEarthBaseDetailsID           = fixedSurfaceEarthBaseDetailsID
        self.mobileSurfaceEarthBaseDetailsID          = mobileSurfaceEarthBaseDetailsID
        self.airborneEarthBaseDetailsID               = airborneEarthBaseDetailsID
    }
}

public extension PolisObservingFacility {
    enum CodingKeys: String, CodingKey {
        case item
        case gravitationalBodyRelationship            = "gravitational_body_relationship"
        case placeInTheSolarSystem                    = "place_in_the_solar_system"
        case observingFacilityCode                    = "observing_facility_code"
        case solarSystemBodyName                      = "solar_system_body_name"
        case orbitingAroundPlaceInTheSolarSystemNamed = "orbiting_around_place_in_the_solar_system_named"
        case facilityLocationID                       = "facility_location_id"
        case astronomicalCode                         = "astronomical_code"
        case parentObservingFacilityID                = "parent_observing_facility_id"
        case observatoryIDs                           = "observatory_ids"
        case deviceIDs                                = "device_ids"
        case website
        case scientificObjectives                     = "scientific_objectives"
        case history
        case fixedSurfaceEarthBaseDetailsID           = "fixed_surface_earth_base_details_id"
        case mobileSurfaceEarthBaseDetailsID          = "mobile_surface_earth_base_details_id"
        case airborneEarthBaseDetailsID               = "airborne_earth_base_details_id"
    }
}

//MARK: - StorableItem Implementation -
extension PolisObservingFacility {
    static func loadFromLocalFileSystemUsing(manager: PolisProviderManager) throws -> AnyObject {
        //TODO: Implement me!
        throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFile
    }

    func parentItem() -> (any StorableItem)? { PolisProviderManager.currentProviderManager.facilityDirectory }

    func flashUsing(manager: PolisProviderManager) throws {
        try ensureFacilityFolderDoesExist()

        //TODO: Implement me!
    }

    func ensureFacilityFolderDoesExist() throws {
        let manager = PolisProviderManager.currentProviderManager!

        if !manager.tryToEnsureFoldersExistence(paths: [facilityPath()]) {
            PolisLogger.shared.error("Cannot create or access facility folder: \(facilityPath())")
            throw PolisProviderManager.PolisProviderManagerError.cannotAccessOrCreateStandardPolisFolder
        }
    }

    func facilityPath() -> String {
        let manager = PolisProviderManager.currentProviderManager!
        return manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: item.identity.id)
    }
}
