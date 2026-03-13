//
//  PolisObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacilityDetails: Identifiable, Codable, Equatable, Sendable {

    // Identification & relationship to other facilities
    public var identity: PolisIdentity
    public var parentObservingFacilityID: UUID?

    // Contains
    public var locationID: UUID?
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

    // Identifiable protocol compliance
    public var id: UUID { identity.id }


    public init(identity: PolisIdentity,
                parentObservingFacilityID: UUID?                  = nil,
                locationID: UUID?                                 = nil,
                observatoryIDs: Set<UUID>?                        = nil,
                deviceIDs: Set<UUID>?                             = nil,
                website: URL?                                     = nil,
                scientificObjectives: String?                     = nil,
                history: String?                                  = nil,
                fixedSurfaceEarthBaseDetailsID: UUID?             = nil,
                mobileSurfaceEarthBaseDetailsID: UUID?            = nil,
                airborneEarthBaseDetailsID: UUID?                 = nil,
                artifactIDs: Set<UUID>?                           = nil) {
        self.identity                                 = identity
        self.parentObservingFacilityID                = parentObservingFacilityID
        self.locationID                               = locationID
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
        case identity
        case parentObservingFacilityID                = "parent_observing_facility_id"
        case locationID                               = "location_id"
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
