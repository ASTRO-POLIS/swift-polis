//
//  PlaceOnEarth.swift
//  swift-polis
//
//  Created by Georg Tuparev on 19.02.26.
//

import Foundation

//open class PlaceOnEarth: PolisObjectPersisting {
open class PlaceOnEarth {

    public private(set) var id: UUID!
    public var lastUpdateTime = Date.now
    public var facilityID: UUID? // We need this because we need to know where to store the JSON file

    public var attentionOff: String?
    public var houseName: String?
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var floor: Int?
    public var apartment: String?
    public var district: String?
    public var site: String?                      // e.g. Mount Wilson
    public var block: String?
    public var zipCode: String?
    public var province: String?
    public var regionOrState: String?             // Region or state name, e.g. California
    public var regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: PolisPlaceOnEarth.EarthContinent?

    public var poBox: String?
    public var poBoxZip: String?

    public var posteRestante: String?

    public var eastLongitude: PolisPropertyValue? // degrees
    public var latitude: PolisPropertyValue?      // degrees
    public var altitude: PolisPropertyValue?      // m

    public var streetLine1: String?
    public var streetLine2: String?
    public var streetLine3: String?
    public var streetLine4: String?
    public var streetLine5: String?
    public var streetLine6: String?

    public var note: String?

    public var timeZoneIdentifier: String?        // .. as defined with `TimeZone.knownTimeZoneIdentifiers`

    //MARK: Internal APIs

    init(_ place: PolisPlaceOnEarth) {
        self._originalPolisRecord = place
        updateFromPolisPlace(place)
     }

    //MARK: Private APIs
    private var _originalPolisRecord: PolisPlaceOnEarth?

    private func updateFromPolisPlace(_ place: PolisPlaceOnEarth) {
        id                 = place.id
        lastUpdateTime     = place.lastUpdateTime
        facilityID         = place.facilityID
        attentionOff       = place.attentionOff
        houseName          = place.houseName
        street             = place.street
        houseNumber        = place.houseNumber
        houseNumberSuffix  = place.houseNumberSuffix
        floor              = place.floor
        apartment          = place.apartment
        district           = place.district
        site               = place.site
        zipCode            = place.zipCode
        province           = place.province
        regionOrState      = place.regionOrState
        regionOrStateCode  = place.regionOrStateCode
        country            = place.country
        countryID          = place.countryID
        continent          = place.continent
        poBox              = place.poBox
        poBoxZip           = place.poBoxZip
        posteRestante      = place.posteRestante
        eastLongitude      = place.eastLongitude
        latitude           = place.latitude
        altitude           = place.altitude
        streetLine1        = place.streetLine1
        streetLine2        = place.streetLine2
        streetLine3        = place.streetLine3
        streetLine4        = place.streetLine4
        streetLine5        = place.streetLine5
        streetLine6        = place.streetLine6
        note               = place.note
        timeZoneIdentifier = place.timeZoneIdentifier
    }

    //MARK: - Implementing PolisObjectPersisting protocol -

}

