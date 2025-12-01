//
//  PolisParty.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20.08.24.
//

import Foundation

//MARK: - PolisParty -
public protocol PolisParty: Codable {
    var name: String                              { get set }
    var email: String                             { get set }
    var communication: PolisCommunicationChannel? { get set }
    var addressIDs: Set<UUID>?                    { get set }
    var note: String?                             { get set }
}

//MARK: - PolisCommunicationChannel -
public struct PolisCommunicationChannel: Codable, Equatable, Sendable {

    /// Twitter user id, e.g. @AstroPolis. "@" is expected to be part of the id.
    public var twitterIDs: [String]?

    public var mastodonIDs: [String]?

    public var blueskyIDs: [String]?

    /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.
    public var instagramIDs: [String]?

    /// Phone number used by WhatsApp. The phone number should include the country code, starting with "+", and contain no
    /// spaces, brackets, or other formatting characters. Currently no validation is provided.
    public var whatsappPhoneNumbers: [String]?

    /// The Facebook user id is only the part of the URL after "www.facebook.com/".
    public var facebookIDs: [String]?

    /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.

    public init(twitterIDs: [String]?           = nil,
                mastodonIDs: [String]?          = nil,
                blueskyIDs: [String]?           = nil,
                instagramIDs: [String]?         = nil,
                whatsappPhoneNumbers: [String]? = nil,
                facebookIDs: [String]?          = nil) {
        self.twitterIDs           = twitterIDs
        self.mastodonIDs          = mastodonIDs
        self.blueskyIDs           = blueskyIDs
        self.instagramIDs         = instagramIDs
        self.whatsappPhoneNumbers = whatsappPhoneNumbers
        self.facebookIDs          = facebookIDs
    }
}

/// `PolisOwnershipType` is used to identify the ownership type of POLIS items (or devices) such as observing facilities, telescopes,
/// CCD cameras, weather stations, etc. Different cases should be self-explanatory. The `private` type should be utilised by
/// amateurs and hobbyists.
public enum PolisOwnershipType: String, Codable, Equatable, Sendable {
    case education   // University, school, ...
    case research
    case commercial
    case network
    case government
    case ngo
    case club
    case consortium
    case cooperative
    case collaboration
    case `private`
    case other
    case unknown
}

/// A type that describes the different kinds of owners of a POLIS item.
///
/// In case the owner claims ownership over a single `PolisItem` the owner's data should be stored together with the Item's
/// data. Otherwise shared ownership is recommended.
public struct PolisOwner: Codable, Equatable, Sendable {
    /// The ownership type as defined by `PolisOwnershipType`
    public var ownershipType: PolisOwnershipType

    /// An optional set of UUIDs pointing to stored `PolisPerson`s.
    public var personalOwnerIDs: Set<UUID>?

    /// An optional set of UUIDs pointing to stored `PolisOrganisation`s.
    public var organisationalOwnerIDs: Set<UUID>?

    public init(ownershipType: PolisOwnershipType  = .other,
                personalOwnerIDs: Set<UUID>?       = nil,
                organisationalOwnerIDs: Set<UUID>? = nil) {
        self.ownershipType          = ownershipType
        self.personalOwnerIDs       = personalOwnerIDs
        self.organisationalOwnerIDs = organisationalOwnerIDs
    }
}

//MARK: - PolisPlace -
public struct PolisPlace: Codable, Equatable, Identifiable, Sendable {

    public enum EarthContinent: String, Codable, Equatable, Sendable {
        case europe       = "Europe"
        case northAmerica = "North America"
        case southAmerica = "South America"
        case africa       = "Africa"
        case asia         = "Asia"
        case oceania      = "Australia and Oceania"
        case antarctica   = "Antarctica"
    }

    public var id: UUID
    public var lastUpdateTime: Date
    public var facilityID: UUID // We need this because we need to know where to store the JSON file

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
    public let regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: EarthContinent?

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

    public init(id: UUID                           = UUID(),
                lastUpdateTime: Date               = Date(),
                facilityID: UUID,
                attentionOff: String?              = nil,
                houseName: String?                 = nil,
                street: String?                    = nil,
                houseNumber: Int?                  = nil,
                houseNumberSuffix: String?         = nil,
                floor: Int?                        = nil,
                apartment: String?                 = nil,
                district: String?                  = nil,
                site: String?                      = nil,
                block: String?                     = nil,
                zipCode: String?                   = nil,
                province: String?                  = nil,
                regionOrState: String?             = nil,
                regionOrStateCode: String?         = nil,
                country: String?                   = nil,
                countryID: String?                 = nil,
                continent: EarthContinent?         = nil,
                poBox: String?                     = nil,
                poBoxZip: String?                  = nil,
                posteRestante: String?             = nil,
                eastLongitude: PolisPropertyValue? = nil,
                latitude: PolisPropertyValue?      = nil,
                altitude: PolisPropertyValue?      = nil,
                streetLine1: String?               = nil,
                streetLine2: String?               = nil,
                streetLine3: String?               = nil,
                streetLine4: String?               = nil,
                streetLine5: String?               = nil,
                streetLine6: String?               = nil,
                note: String?                      = nil,
                timeZoneIdentifier: String?        = nil) {
        self.id                 = id
        self.lastUpdateTime     = lastUpdateTime
        self.facilityID         = facilityID
        self.attentionOff       = attentionOff
        self.houseName          = houseName
        self.street             = street
        self.houseNumber        = houseNumber
        self.houseNumberSuffix  = houseNumberSuffix
        self.floor              = floor
        self.apartment          = apartment
        self.district           = district
        self.site               = site
        self.block              = block
        self.zipCode            = zipCode
        self.province           = province
        self.regionOrState      = regionOrState
        self.regionOrStateCode  = regionOrStateCode
        self.country            = country
        self.countryID          = countryID
        self.continent          = continent
        self.poBox              = poBox
        self.poBoxZip           = poBoxZip
        self.posteRestante      = posteRestante
        self.eastLongitude      = eastLongitude
        self.latitude           = latitude
        self.altitude           = altitude
        self.streetLine1        = streetLine1
        self.streetLine2        = streetLine2
        self.streetLine3        = streetLine3
        self.streetLine4        = streetLine4
        self.streetLine5        = streetLine5
        self.streetLine6        = streetLine6
        self.note               = note
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

//MARK: - PolisPerson -
public struct PolisPerson: PolisParty, Equatable, Sendable {
    public var name: String
    public var email: String
    public var communication: PolisCommunicationChannel?
    public var addressIDs: Set<UUID>?
    public var note: String?

    public init(name: String, email: String, communication: PolisCommunicationChannel? = nil, addressIDs: Set<UUID>? = nil, note: String? = nil) {
        self.name          = name
        self.email         = email
        self.communication = communication
        self.addressIDs    = addressIDs
        self.note          = note
    }
}

//MARK: - PolisOrganisation -
public struct PolisOrganisation: PolisParty, Equatable, Sendable {
    public var organisationType: PolisOwnershipType
    public var email: String
    public var name: String
    public var communication: PolisCommunicationChannel?
    public var addressIDs: Set<UUID>?
    public var note: String?
    public var url: URL?
    public let abbreviation: String?   // e.g. MIT. MONET, BAO, ...

    public init(organisationType: PolisOwnershipType       = .other,
                name: String, email: String,
                communication: PolisCommunicationChannel? = nil,
                addressIDs: Set<UUID>?                    = nil,
                note: String?                             = nil,
                url: URL?                                 = nil,
                abbreviation: String?                     = nil) {
        self.organisationType = organisationType
        self.name             = name
        self.email            = email
        self.communication    = communication
        self.addressIDs       = addressIDs
        self.note             = note
        self.url              = url
        self.abbreviation     = abbreviation
    }
}

//MARK: - Type extensions -

//MARK: - PolisCommunicationChannel
extension PolisCommunicationChannel {
    public enum CodingKeys: String, CodingKey {
        case twitterIDs           = "twitter_ids"
        case mastodonIDs          = "mastodon_ids"
        case blueskyIDs           = "bluesky_ids"
        case instagramIDs         = "instagram_ids"
        case whatsappPhoneNumbers = "whatsapp_phone_numbers"
        case facebookIDs          = "facebook_ids"
    }
}

//MARK: - PolisAddress
extension PolisPlace {
    public enum CodingKeys: String, CodingKey {
        case id
        case lastUpdateTime     = "last_update_time"
        case facilityID         = "facility_id"

        case attentionOff       = "attention_off"
        case houseName          = "house_name"
        case street
        case houseNumber        = "house_number"
        case houseNumberSuffix  = "house_number_suffix"
        case floor
        case apartment
        case district
        case site
        case block
        case zipCode            = "zip_code"
        case province
        case regionOrState      = "region_or_state"
        case regionOrStateCode  = "region_or_state_code"

        case country
        case countryID          = "country_id"

        case continent

        case poBox              = "po_box"
        case poBoxZip           = "po_box_zip"

        case posteRestante      = "poste_restante"

        case eastLongitude      = "east_longitude"
        case latitude
        case altitude

        case streetLine1        = "street_line_1"
        case streetLine2        = "street_line_2"
        case streetLine3        = "street_line_3"
        case streetLine4        = "street_line_4"
        case streetLine5        = "street_line_5"
        case streetLine6        = "street_line_6"

        case note

        case timeZoneIdentifier = "time_zone_identifier"
    }
}

//MARK: - PolisPerson -
extension PolisPerson {
    public enum CodingKeys: String, CodingKey {
        case name
        case email
        case communication
        case addressIDs     = "address_ids"
        case note
    }
}

//MARK: - PolisOrganisation -
extension PolisOrganisation {
    public enum CodingKeys: String, CodingKey {
        case organisationType = "organisation_type"
        case name
        case email
        case communication
        case addressIDs       = "address_ids"
        case note
        case url
        case abbreviation
    }
}

public extension PolisOwner {
    enum CodingKeys: String, CodingKey {
        case ownershipType          = "ownership_type"
        case personalOwnerIDs       = "personal_owner_ids"
        case organisationalOwnerIDs = "organisational_owner_ids"

    }
}
