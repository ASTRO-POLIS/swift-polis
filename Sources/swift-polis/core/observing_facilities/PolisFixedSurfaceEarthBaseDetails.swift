//
//  PolisFixedSurfaceEarthBaseDetails.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/10/2024.
//

import Foundation

public struct PolisFixedSurfaceEarthBaseDetails: Identifiable, Codable, StorableItem, Equatable {

    public var location: PolisPlace?

    // General info
    public var id: UUID
    public var facility: PolisObservingFacility
    public var visitingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    public var placeID: UUID?

    public init(id: UUID                                              = UUID(),
                facility: PolisObservingFacility,
                location: PolisPlace?                                 = nil,
                visitingHours: PolisVisitingHours?                    = nil,
                averageClearNightsPerYear: UInt?                      = nil,
                averageSeeingConditions: PolisPropertyValue?          = nil,
                traditionalLandOwners: String?                        = nil,
                dominantWindDirection: PolisDirection.RoughDirection? = nil,
                surfaceSize: PolisPropertyValue?                      = nil,
                placeID: UUID?                                        = nil) {
        self.id                        = id
        self.facility                  = facility
        self.location                  = location
        self.visitingHours             = visitingHours
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.traditionalLandOwners     = traditionalLandOwners
        self.dominantWindDirection     = dominantWindDirection
        self.surfaceSize               = surfaceSize
        self.placeID                   = placeID
    }
}

public extension PolisFixedSurfaceEarthBaseDetails {
    enum CodingKeys: String, CodingKey {
        case id
        case facility
        case location
        case visitingHours             = "visiting_hours"
        case accessRestrictions        = "access_restrictions"
        case averageClearNightsPerYear = "average_clear_nights_per_year"
        case averageSeeingConditions   = "average_seeing_conditions"
        case averageSkyQuality         = "average_sky_quality"
        case traditionalLandOwners     = "traditionalLand_owners"
        case dominantWindDirection     = "'dominant_wind_direction'"
        case surfaceSize               = "surface_size"
        case placeID                   = "place_id"
    }
}

//MARK: - StorableItem Implementation -
extension PolisFixedSurfaceEarthBaseDetails {
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
        return manager.polisFileResourceFinder.observingFacilityFolder(observingFacilityID: facility.item.identity.id)
    }
}
