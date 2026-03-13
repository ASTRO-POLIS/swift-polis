//
//  PolisObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacilityDetails: Identifiable, Codable, Equatable, Sendable {

    // Identification and type
    public var item: PolisItem


    // Relationship to other facilities
    //TODO: We do not need a parent facility! Item has a parent!
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
                parentObservingFacilityID: UUID?                  = nil,
                observatoryIDs: Set<UUID>?                        = nil,
                deviceIDs: Set<UUID>?                             = nil,
                website: URL?                                     = nil,
                scientificObjectives: String?                     = nil,
                history: String?                                  = nil,
                fixedSurfaceEarthBaseDetailsID: UUID?             = nil,
                mobileSurfaceEarthBaseDetailsID: UUID?            = nil,
                airborneEarthBaseDetailsID: UUID?                 = nil,
                artifactIDs: Set<UUID>?                           = nil) {
        self.item                                     = item
        self.parentObservingFacilityID                = parentObservingFacilityID
        self.observatoryIDs                           = observatoryIDs
        self.deviceIDs                                = deviceIDs
        self.website                                  = website
        self.scientificObjectives                     = scientificObjectives
        self.history                                  = history
        self.fixedSurfaceEarthBaseDetailsID           = fixedSurfaceEarthBaseDetailsID
        self.mobileSurfaceEarthBaseDetailsID          = mobileSurfaceEarthBaseDetailsID
        self.airborneEarthBaseDetailsID               = airborneEarthBaseDetailsID
        self.artifactIDs                              = artifactIDs
    }
}

public extension PolisObservingFacilityDetails {
    enum CodingKeys: String, CodingKey {
        case item
        case parentObservingFacilityID                = "parent_observing_facility_id"
        case observatoryIDs                           = "observatory_ids"
        case deviceIDs                                = "device_ids"
        case website
        case scientificObjectives                     = "scientific_objectives"
        case history
        case fixedSurfaceEarthBaseDetailsID           = "fixed_surface_earth_base_details_id"
        case mobileSurfaceEarthBaseDetailsID          = "mobile_surface_earth_base_details_id"
        case airborneEarthBaseDetailsID               = "airborne_earth_base_details_id"
        case artifactIDs                              = "artifact_ids"
    }
}
