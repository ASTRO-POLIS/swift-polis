//
//  PolisObservingFacilityDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 25/09/2024.
//

import Foundation

public struct PolisObservingFacilityDetails: Identifiable, Codable, Equatable, Sendable, PolisObject {

    //MARK: Identification & relationship to other facilities
    public var id: UUID
    public var lastUpdateTime: Date

    public var facilityID: UUID

    //MARK: Contains
    public var typeSpecificDetailsID: UUID?  // e.g.PolisEarthFixedBaseObservingFacilityDetails, satellites, ...
    public var observatoryIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?
    public var ownerID: UUID?          // Who are the owners of the POLIS Item?
    public var mediaSourceID: UUID?    // Defines a set of media sources (images, audio etc) attached to the POLIS Item
    public var artifactIDs: Set<UUID>? // Arifacts of interest could be also on other solar system bodies (e.g. Apollo landing site)

    //MARK: Info
    public var website: URL?
    public var scientificObjectives: LocalisableString?
    public var history: LocalisableString?

    public init(id: UUID,
                lastUpdateTime: Date                     = Date.now,
                facilityID: UUID,

                typeSpecificDetailsID: UUID?             = nil,
                observatoryIDs: Set<UUID>?               = nil,
                deviceIDs: Set<UUID>?                    = nil,
                ownerID: UUID?                           = nil,
                mediaSourceID: UUID?                     = nil,
                artifactIDs: Set<UUID>?                  = nil,

                website: URL?                            = nil,
                scientificObjectives: LocalisableString? = nil,
                history: LocalisableString?              = nil) {
        self.id                        = id
        self.lastUpdateTime            = lastUpdateTime
        self.facilityID                = facilityID

        self.typeSpecificDetailsID     = typeSpecificDetailsID
        self.observatoryIDs            = observatoryIDs
        self.deviceIDs                 = deviceIDs
        self.ownerID                   = ownerID
        self.mediaSourceID             = mediaSourceID
        self.artifactIDs               = artifactIDs

        self.website                   = website
        self.scientificObjectives      = scientificObjectives
        self.history                   = history
    }

    func polisDataType() -> PolisDataType { .observingFacilityDetail }
}

public extension PolisObservingFacilityDetails {
    enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateTime            = "last_update_time"
        case facilityID                = "facility_id"

        case typeSpecificDetailsID     = "type_specific_details_id"
        case observatoryIDs            = "observatory_ids"
        case deviceIDs                 = "device_ids"
        case ownerID                   = "owner_id"
        case mediaSourceID             = "media_source_id"
        case artifactIDs               = "artifact_ids"

        case website
        case scientificObjectives      = "scientific_objectives"
        case history
    }
}
