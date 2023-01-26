//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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
    var parentObservingSiteID: UUID?                  { get set }
    var subObservingSiteIDs: Set<UUID>                { get set }
    var observatoryCode: String?                      { get set } // IAU or MPC (Minor Planet Center) code
    var deviceIDs: Set<UUID>                          { get set }
    var suggestedSubDeviceIDs: Set<UUID>              { get set }
    var configurationIDs: Set<UUID>                   { get set }
    var siteLocation: PolisObservingSiteLocationType? { get set }
    var startDate: Date?                              { get set } // Could be nil if unknown
    var endDate: Date?                                { get set } // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    var admins: [PolisAdminContact]?                  { get set }
    var website: URL?                                 { get set }
    var scientificObjectives: String?                 { get set }
}

public struct PolisEarthObservingSite: PolisObserving {
    public var type: PolisObservingType
    public var item: PolisItem
    public var parentObservingSiteID: UUID?
    public var subObservingSiteIDs                           = Set<UUID>()
    public var observatoryCode: String?
    public var deviceIDs                                     = Set<UUID>()
    public var suggestedSubDeviceIDs                         = Set<UUID>()
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

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisMeasurement? // [arcsec]
    public var averageSkyQuality: PolisMeasurement?       // [magnitude]

    public var traditionalLandOwners: String?
    public var history: String?

    public var id: UUID { item.identity.id }

    // Miscellaneous properties
    public var dominantWindDirection: PolisDirection.RoughDirection?

    //TODO: Add observing site climate information
    // - Min/Max/Average climate parameters / season

    public init(type: PolisObservingType                               = .site,
                item: PolisItem,
                parentObservingSiteID: UUID?                           = nil,
                subObservingSiteIDs:  Set<UUID>                        = Set<UUID>(),
                observatoryCode: String?                               = nil,
                deviceIDs: Set<UUID>                                   = Set<UUID>(),
                suggestedSubDeviceIDs: Set<UUID>                       = Set<UUID>(),
                configurationIDs: Set<UUID>                            = Set<UUID>(),
                siteLocation: PolisObservingSiteLocationType?          = nil,
                startDate: Date?                                       = nil,
                endDate: Date?                                         = nil,
                admins: [PolisAdminContact]?                           = nil,
                website: URL?                                          = nil,
                scientificObjectives: String?                          = nil,
                workingHours: PolisActivityPeriods?                    = nil,
                openingHours: PolisActivityPeriods?                    = nil,
                accessRestrictions: String?                            = nil,
                averageClearNightsPerYear: UInt?                       = nil,
                averageSeeingConditions: PolisMeasurement?             = nil,
                averageSkyQuality: PolisMeasurement?                   = nil,
                traditionalLandOwners: String?                         = nil,
                history: String?                                       = nil,
                dominantWindDirection: PolisDirection.RoughDirection?  = nil) {
        self.type                      = type
        self.item                      = item
        self.parentObservingSiteID     = parentObservingSiteID
        self.subObservingSiteIDs       = subObservingSiteIDs
        self.observatoryCode           = observatoryCode
        self.deviceIDs                 = deviceIDs
        self.suggestedSubDeviceIDs     = suggestedSubDeviceIDs
        self.configurationIDs          = configurationIDs
        self.siteLocation              = siteLocation
        self.startDate                 = startDate
        self.endDate                   = endDate
        self.admins                    = admins
        self.website                   = website
        self.scientificObjectives      = scientificObjectives
        self.workingHours              = workingHours
        self.openingHours              = openingHours
        self.accessRestrictions        = accessRestrictions
        self.averageClearNightsPerYear = averageClearNightsPerYear
        self.averageSeeingConditions   = averageSeeingConditions
        self.averageSkyQuality         = averageSkyQuality
        self.traditionalLandOwners     = traditionalLandOwners
        self.history                   = history
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
public extension PolisEarthObservingSite {
    enum CodingKeys: String, CodingKey {
        case type
        case item
        case parentObservingSiteID      = "paren_observing_site_id"
        case subObservingSiteIDs        = "subObservingSite_ids"
        case observatoryCode            = "observatory_code"
        case deviceIDs                  = "device_ids"
        case suggestedSubDeviceIDs      = "suggested_sub_device_ids"
        case configurationIDs           = "configuration_ids"
        case siteLocation               = "site_location"
        case startDate                  = "start_date"
        case endDate                    = "end_date"
        case admins
        case website
        case scientificObjectives       = "scientific_objectives"
        case workingHours               = "working_hours"
        case openingHours               = "opening_hours"
        case accessRestrictions         = "access_restrictions"
        case averageClearNightsPerYear  = "average_clear_nights_per_year"
        case averageSeeingConditions    = "average_seeing_conditions"
        case averageSkyQuality          = "average_sky_quality"
        case traditionalLandOwners      = "traditional_land_owners"
        case history
        case dominantWindDirection      = "dominant_wind_direction"
    }
}
