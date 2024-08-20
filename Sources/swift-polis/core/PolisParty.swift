//
//  PolisParty.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20.08.24.
//

import Foundation

//MARK: - PolisParty -
public protocol PolisParty {
    func name() -> String?
    func set(name: String)

    func communicationChannel() -> PolisCommunicationChannel?
    func set(communicationChannel: PolisCommunicationChannel)

    func address() -> PolisAddress?
    func set(address: PolisAddress)
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

//MARK: - PolisAddress -
public struct PolisAddress: Codable {
    public var attentionOff: String?
    public var houseName: String?
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var floor: Int?
    public var apartment: String?
    public var district: String?
    public var place: String?
    public var block: String?
    public var zipCode: String?
    public var province: String?
    public var region: String?
    public var state: String?

    public var countryID: String? // 2-letter code

    public var poBox: String?
    public var poBoxZip: String?

    public var posteRestante: String?

    public var latitude: Double?
    public var longitude: Double?

    public var streetLine1: String?
    public var streetLine2: String?
    public var streetLine3: String?
    public var streetLine4: String?
    public var streetLine5: String?
    public var streetLine6: String?

    public var note: String?

    public init(attentionOff: String?      = nil,
                houseName: String?         = nil,
                street: String?            = nil,
                houseNumber: Int?          = nil,
                houseNumberSuffix: String? = nil,
                floor: Int?                = nil,
                apartment: String?         = nil,
                district: String?          = nil,
                place: String?             = nil,
                block: String?             = nil,
                zipCode: String?           = nil,
                province: String?          = nil,
                region: String?            = nil,
                state: String?             = nil,
                countryID: String?         = nil,
                poBox: String?             = nil,
                poBoxZip: String?          = nil,
                posteRestante: String?     = nil,
                latitude: Double?          = nil,
                longitude: Double?         = nil,
                streetLine1: String?       = nil,
                streetLine2: String?       = nil,
                streetLine3: String?       = nil,
                streetLine4: String?       = nil,
                streetLine5: String?       = nil,
                streetLine6: String?       = nil,
                note: String?              = nil) {
        self.attentionOff      = attentionOff
        self.houseName         = houseName
        self.street            = street
        self.houseNumber       = houseNumber
        self.houseNumberSuffix = houseNumberSuffix
        self.floor             = floor
        self.apartment         = apartment
        self.district          = district
        self.place             = place
        self.block             = block
        self.zipCode           = zipCode
        self.province          = province
        self.region            = region
        self.state             = state
        self.countryID         = countryID
        self.poBox             = poBox
        self.poBoxZip          = poBoxZip
        self.posteRestante     = posteRestante
        self.latitude          = latitude
        self.longitude         = longitude
        self.streetLine1       = streetLine1
        self.streetLine2       = streetLine2
        self.streetLine3       = streetLine3
        self.streetLine4       = streetLine4
        self.streetLine5       = streetLine5
        self.streetLine6       = streetLine6
        self.note              = note
    }
}

//MARK: - PolisPerson -
public struct PolisPerson: Codable {

}

//MARK: - PolisOrganisation -
public struct PolisOrganisation: Codable {

}

//MARK: - Type extensions -

extension PolisParty {
    func name() -> String? { nil }
    func set(name: String) { }

    func communicationChannel() -> PolisCommunicationChannel? { nil }
    func set(communicationChannel: PolisCommunicationChannel) { }

    func address() -> PolisAddress? { nil }
    func set(address: PolisAddress) { }
}

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

//MARK: - PolisAddress
extension PolisAddress {
    public enum CodingKeys: String, CodingKey {
        case attentionOff      = "attention_off"
        case houseName         = "house_name"
        case street
        case houseNumber       = "house_number"
        case houseNumberSuffix = "house_number_suffix"
        case floor
        case apartment
        case district
        case place
        case block
        case zipCode           = "zip_code"
        case province
        case region
        case state

        case countryID         = "country_id"

        case poBox             = "po_box"
        case poBoxZip          = "po_box_zip"

        case posteRestante     = "poste_restante"

        case latitude
        case longitude

        case streetLine1       = "street_line_1"
        case streetLine2       = "street_line_2"
        case streetLine3       = "street_line_3"
        case streetLine4       = "street_line_4"
        case streetLine5       = "street_line_5"
        case streetLine6       = "street_line_6"

        case note
    }
}
