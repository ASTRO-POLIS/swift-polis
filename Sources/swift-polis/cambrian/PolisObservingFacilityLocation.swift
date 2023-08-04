//===----------------------------------------------------------------------===//
//  PolisObservingFacilityLocation.swift
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

public struct PolisObservingFacilityLocation: Codable {

    public enum EarthContinent: String, Codable {
        case europe       = "Europe"
        case northAmerica = "North America"
        case southAmerica = "South America"
        case africa       = "Africa"
        case asia         = "Asia"
        case oceania      = "Australia and Oceania"
        case antarctica   = "Antarctica"
    }


    //MARK: - Common properties
    public let eastLongitude: PolisPropertyValue? // degrees
    public let latitude: PolisPropertyValue?      // degrees
    public let altitude: PolisPropertyValue?      // m
    public var regionName: String?                // e.g. "Sea of Tranquility" on the Moon, "Atacama desert" on the Earth, or "Terra Sabaea" on Mars
    public let place: String?                     // e.g. Mount Wilson

    //MARK: - Earth location
    public var earthTimeZoneIdentifier: String?   // .. as defined with `TimeZone.knownTimeZoneIdentifiers`
    public var earthContinent: EarthContinent?
    public let earthRegionOrStateName: String?    // e.g. California
    public let earthRegionOrStateCode: String?    // e.g. CA for California
    public let earthZipCode: String?              // e.g. 12345
    public let earthCountry: String?              // e.g. Armenia
    public let earthCountryCode: String?          // 2-letter code.

    init(eastLongitude: PolisPropertyValue?, latitude: PolisPropertyValue?, altitude: PolisPropertyValue?, regionName: String? = nil, place: String?, earthTimeZoneIdentifier: String? = nil, earthContinent: EarthContinent? = nil, earthRegionOrStateName: String?, earthRegionOrStateCode: String?, earthZipCode: String?, earthCountry: String?, earthCountryCode: String?) {
        self.eastLongitude = eastLongitude
        self.latitude = latitude
        self.altitude = altitude
        self.regionName = regionName
        self.place = place
        self.earthTimeZoneIdentifier = earthTimeZoneIdentifier
        self.earthContinent = earthContinent
        self.earthRegionOrStateName = earthRegionOrStateName
        self.earthRegionOrStateCode = earthRegionOrStateCode
        self.earthZipCode = earthZipCode
        self.earthCountry = earthCountry
        self.earthCountryCode = earthCountryCode
    }

}

public extension PolisObservingFacilityLocation {
    enum CodingKeys: String, CodingKey {
        case eastLongitude           = "east_longitude"
        case latitude
        case altitude
        case regionName              = "region_name"
        case place

        //MARK: - Earth location
        case earthTimeZoneIdentifier = "earth_time_zone_identifier"
        case earthContinent          = "earth_continent"
        case earthRegionOrStateName  = "earth_region_or_state_name"
        case earthRegionOrStateCode  = "earth_region_or_state_code"
        case earthZipCode            = "earth_zip_code"
        case earthCountry            = "earth_country"
        case earthCountryCode        = "earth_country_code"
    }
}
