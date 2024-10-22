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
    var address: PolisAddress?                    { get set }
    var note: String?                             { get set }
}

//MARK: - PolisCommunicationChannel -
public struct PolisCommunicationChannel: Codable {

    /// Twitter user id, e.g. @AstroPolis. "@" is expected to be part of the id.
    public var twitterIDs: [String]?

    public var mastodonIDs: [String]?

    /// Phone number used by WhatsApp. The phone number should include the country code, starting with "+", and contain no
    /// spaces, brackets, or other formatting characters. Currently no validation is provided.
    public var whatsappPhoneNumbers: [String]?

    /// The Facebook user id is only the part of the URL after "www.facebook.com/".
    public var facebookIDs: [String]?

    /// Instagram user id, e.g. @AstroPolis. "@" is expected to be part of the id.
    public var instagramIDs: [String]?

    /// Skype user id
    public var skypeIDs: [String]?

    public init(twitterIDs: [String]?           = nil,
                mastodonIDs: [String]?          = nil,
                whatsappPhoneNumbers: [String]? = nil,
                facebookIDs: [String]?          = nil,
                instagramIDs: [String]?         = nil,
                skypeIDs: [String]?             = nil) {
        self.twitterIDs           = twitterIDs
        self.mastodonIDs          = mastodonIDs
        self.whatsappPhoneNumbers = whatsappPhoneNumbers
        self.facebookIDs          = facebookIDs
        self.instagramIDs         = instagramIDs
        self.skypeIDs             = skypeIDs
    }
}

/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing facility owner, or an observatory
/// admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an
/// observing facility, but one should not forget that all POLIS data is publicly available and therefore should not
/// expose private information if possible. It is preferable not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts or pages.
///
/// The type implements the `Codable` protocol.
public struct PolisAdminContact: Identifiable {

    /// `Communication` defines different types of communication channels in addition to the default email address and
    /// mobile number.
    ///
    /// The current list includes just a handful of popular communication channels. Emerging apps like Signal and Telegram
    /// are not currently included, nor are local Chinese and Russian social media communication channels. If you need
    /// such channels, please submit a pull request to the POLIS developers.
    ///
    /// The type implements the `Codable` protocol and is thus JSON-representable.

    /// The admin's unique identifier.
    ///
    /// An administrator needs a unique identifier in order to define login credentials and identify sources of data changes and contributions.
    public let id: UUID

    /// The admin's name.
    ///
    /// It is recommended that an admin's name is either omitted or describes the admin's role, e.g. "Managing
    /// Director of Mountain Observatory"
    public var name: String?

    /// The admin's email address.
    ///
    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect privacy, it is recommended that the email address is assigned to the institution,
    /// e.g. "office@mountain-observatory.org". A valid email is expected.
    public var emailAddress: String

    /// The admin's phone number.
    ///
    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var phoneNumber: String?

    /// An array of additional communication channels for contacting the admin, if applicable.
    public var communication: PolisCommunicationChannel?

    /// Miscellaneous information that doesn't fit in any other property.
    ///
    /// Notes can contain additional information on how to contact the admin, such as "The admin could be contacted only during office hours," or "The admin is
    /// on vacation from 01/12 to 20/12."
    public var note: String?

    /// Designated initialiser.
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.

    public init?(id:                              UUID     = UUID(),
                 name:                            String?,
                 emailAddress:                    String,
                 phoneNumber:                     String?  = nil,
                 communication: PolisCommunicationChannel? = nil,
                 note:                           String?   = nil) {
        guard emailAddress.isValidEmailAddress() else { return nil }

        self.id            = id
        self.name          = name
        self.emailAddress  = emailAddress
        self.phoneNumber   = phoneNumber
        self.communication = communication
        self.note          = note
    }

}

/// `PolisOwnershipType` is used to identify the ownership type of POLIS items (or devices) such as observing facilities, telescopes,
/// CCD cameras, weather stations, etc. Different cases should be self-explanatory. The `private` type should be utilised by
/// amateurs and hobbyists.
public enum PolisOwnershipType: String, Codable {
    case university
    case research
    case commercial
    case school
    case network
    case government
    case ngo
    case club
    case consortium
    case cooperative
    case collaboration
    case `private`
    case other
}

//MARK: - PolisAddress -
public struct PolisAddress: Codable {

    public enum EarthContinent: String, Codable {
        case europe       = "Europe"
        case northAmerica = "North America"
        case southAmerica = "South America"
        case africa       = "Africa"
        case asia         = "Asia"
        case oceania      = "Australia and Oceania"
        case antarctica   = "Antarctica"
    }

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
    public var region: String?                    // Region or state name, e.g. California
    public let regionCode: String?                // e.g. CA for California

    public var state: String?

    public let country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: EarthContinent?

    public var poBox: String?
    public var poBoxZip: String?

    public var posteRestante: String?

    public let eastLongitude: PolisPropertyValue? // degrees
    public let latitude: PolisPropertyValue?      // degrees
    public let altitude: PolisPropertyValue?      // m

    public var streetLine1: String?
    public var streetLine2: String?
    public var streetLine3: String?
    public var streetLine4: String?
    public var streetLine5: String?
    public var streetLine6: String?

    public var note: String?

    public var timeZoneIdentifier: String?        // .. as defined with `TimeZone.knownTimeZoneIdentifiers`

    public init(attentionOff: String?              = nil,
                houseName: String?                 = nil,
                street: String?                    = nil,
                houseNumber: Int?                  = nil,
                houseNumberSuffix: String?         = nil,
                floor: Int?                        = nil,
                apartment: String?                 = nil,
                district: String?                  = nil,
                place: String?                     = nil,
                block: String?                     = nil,
                zipCode: String?                   = nil,
                province: String?                  = nil,
                region: String?                    = nil,
                regionCode: String?                = nil,
                country: String?                   = nil,
                state: String?                     = nil,
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
        self.attentionOff       = attentionOff
        self.houseName          = houseName
        self.street             = street
        self.houseNumber        = houseNumber
        self.houseNumberSuffix  = houseNumberSuffix
        self.floor              = floor
        self.apartment          = apartment
        self.district           = district
        self.place              = place
        self.block              = block
        self.zipCode            = zipCode
        self.province           = province
        self.region             = region
        self.regionCode         = regionCode
        self.state              = state
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
public struct PolisPerson: PolisParty {
    public var name: String
    public var email: String
    public var communication: PolisCommunicationChannel?
    public var address: PolisAddress?
    public var note: String?

    public init(name: String, email: String, communication: PolisCommunicationChannel? = nil, address: PolisAddress? = nil, note: String? = nil) {
        self.name          = name
        self.email         = email
        self.communication = communication
        self.address       = address
        self.note          = note
    }
}

//MARK: - PolisOrganisation -
public struct PolisOrganisation: PolisParty {
    public var organisationType: PolisOwnershipType
    public var email: String
    public var name: String
    public var communication: PolisCommunicationChannel?
    public var address: PolisAddress?
    public var note: String?
    public var url: URL?
    public let abbreviation: String?   // e.g. MIT. MONET, BAO, ...

    public init(organisationType: PolisOwnershipType       = .other,
                name: String, email: String,
                communication: PolisCommunicationChannel? = nil,
                address: PolisAddress?                    = nil,
                note: String?                             = nil,
                url: URL?                                 = nil,
                abbreviation: String?                     = nil) {
        self.organisationType = organisationType
        self.name             = name
        self.email            = email
        self.communication    = communication
        self.address          = address
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
        case whatsappPhoneNumbers = "whatsapp_phone_numbers"
        case facebookIDs          = "facebook_ids"
        case instagramIDs         = "instagram_ids"
        case skypeIDs             = "skype_ids"
    }
}

extension PolisAdminContact: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case emailAddress = "email_address"
        case phoneNumber  = "phone_number"
        case communication
        case note
    }
}


//MARK: - PolisAddress
extension PolisAddress {
    public enum CodingKeys: String, CodingKey {
        case attentionOff       = "attention_off"
        case houseName          = "house_name"
        case street
        case houseNumber        = "house_number"
        case houseNumberSuffix  = "house_number_suffix"
        case floor
        case apartment
        case district
        case place
        case block
        case zipCode            = "zip_code"
        case province
        case region
        case regionCode         = "region_code"
        case state

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
        case address
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
        case address
        case note
        case url
        case abbreviation
    }
}
