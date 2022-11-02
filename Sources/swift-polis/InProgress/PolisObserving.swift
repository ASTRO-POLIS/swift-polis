//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//


import Foundation

public enum PolisObservingType: String, Codable {
    case site
    case mobilePlatform
    case collaboration
    case network
    case array
}

public protocol PolisObserving: Codable, Identifiable {
    var type: PolisObservingType                      { get }
    var item: PolisItem                               { get set }
    var observatoryCode: String?                      { get set } // IAU or MPC (Minor Planet Center) code
    var deviceIDs: Set<UUID>                          { get set }
    var configurationIDs: Set<UUID>                   { get set }
    var siteLocation: PolisObservingSiteLocationType? { get set }
    var startDate: Date?                              { get set } // Could be nil if unknown
    var endDate: Date?                                { get set } // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    var admins: [PolisAdminContact]?                  { get set }
}

public struct PolisObservingSite: PolisObserving {
    public var type: PolisObservingType
    public var item: PolisItem
    public var observatoryCode: String?
    public var deviceIDs                                     = Set<UUID>()
    public var configurationIDs                              = Set<UUID>()
    public var siteLocation: PolisObservingSiteLocationType?
    public var startDate: Date?
    public var endDate: Date?
    public var admins: [PolisAdminContact]?
    public var website: URL?
    public var scientificObjectives: String?

    public var workingHours: PolisActivityPeriods?
    public var openingHours: PolisActivityPeriods?
    public var accessRestrictions: String?

    public var averageClearNightsYear: UInt?
    public var averageSeeingConditions: PolisMeasurement? // [arcec]
    public var averageSkyQuality: Double?                 // [magnitude]

    public var traditionalLandOwners: String?

    public var subObservingSiteIDs: Set<UUID>?

    public var id: UUID { item.identity.id }

    // Miscellaneous properties
    public var dominantWindDirection: PolisDirection.RoughDirection?

    //TODO: We need to add few things
    // - Is accessible by road and all seasons
    // - Visiting hours and possibilities -> WebSite?
    // - Min/Max/Average climate parameters / season
    // - History (this perhaps is a property of PolisObserving?)

    public init(type: PolisObservingType                       = .site,
                item: PolisItem,
                observatoryCode: String?                       = nil,
                deviceIDs: Set<UUID>                           = Set<UUID>(),
                configurationIDs: Set<UUID>                    = Set<UUID>(),
                siteLocation: PolisObservingSiteLocationType?  = nil,
                startDate: Date?                               = nil,
                endDate: Date?                                 = nil,
                admins: [PolisAdminContact]?                   = nil,
                website: URL?                                  = nil,
                scientificObjectives: String?                  = nil,
                workingHours: PolisActivityPeriods?            = nil,
                openingHours: PolisActivityPeriods?            = nil,
                accessRestrictions: String?                    = nil,
                averageClearNightsYear: UInt?                  = nil,
                averageSeeingConditions: PolisMeasurement?     = nil,
                averageSkyQuality: Double?                     = nil,
                traditionalLandOwners: String?                 = nil,
                subObservingSiteIDs: Set<UUID>?                = nil) {
        self.type                    = type
        self.item                    = item
        self.observatoryCode         = observatoryCode
        self.deviceIDs               = deviceIDs
        self.configurationIDs        = configurationIDs
        self.siteLocation            = siteLocation
        self.startDate               = startDate
        self.endDate                 = endDate
        self.admins                  = admins
        self.website                 = website
        self.scientificObjectives    = scientificObjectives
        self.workingHours            = workingHours
        self.openingHours            = openingHours
        self.accessRestrictions      = accessRestrictions
        self.averageClearNightsYear  = averageClearNightsYear
        self.averageSeeingConditions = averageSeeingConditions
        self.averageSkyQuality       = averageSkyQuality
        self.traditionalLandOwners   = traditionalLandOwners
        self.subObservingSiteIDs     = subObservingSiteIDs
    }
}


//MARK: - Type extensions -

public extension PolisObservingType {
    enum CodingKeys: String, CodingKey {
        case site
        case mobilePlatform = "mobile_platform"
        case collaboration
        case network
        case array
    }
}


//MARK: - Observing Site
public extension PolisObservingSite {
    enum CodingKeys: String, CodingKey {
        case type
        case item
        case observatoryCode         = "observatory_code"
        case deviceIDs               = "device_ids"
        case configurationIDs        = "configuration_ids"
        case siteLocation            = "site_location"
        case startDate               = "start_date"
        case endDate                 = "end_date"
        case admins
        case website
        case scientificObjectives    = "scientific_objectives"
        case workingHours            = "working_hours"
        case openingHours            = "opening_hours"
        case accessRestrictions      = "access_restrictions"
        case subObservingSiteIDs     = "sub_observing_site_ids"
        case averageClearNightsYear  = "average_clear_nights_year"
        case averageSeeingConditions = "average_seeing_conditions"
        case averageSkyQuality       = "average_sky_quality"
        case traditionalLandOwners   = "traditional_land_owners"
        case dominantWindDirection   = "dominant_wind_direction"
    }
}
