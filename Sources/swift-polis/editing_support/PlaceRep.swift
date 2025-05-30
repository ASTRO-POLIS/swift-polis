//
//  PlaceRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 30.05.25.
//

import Foundation

open class PlaceRep: IdentifiablePersistentItem {

    public var attentionOff: String?
    public var houseName: String?
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var floor: Int?
    public var apartment: String?
    public var district: String?
    public var place: String?                     // e.g. Mount Wilson
    public var block: String?
    public var zipCode: String?
    public var province: String?
    public var regionOrState: String?             // Region or state name, e.g. California
    public var regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: PolisPlace.EarthContinent?

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

}
