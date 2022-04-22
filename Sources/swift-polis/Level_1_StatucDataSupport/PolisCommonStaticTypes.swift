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
import SoftwareEtudesUtilities

//MARK: - Communication related types -

// Many POLIS types have reference to contact people (owners of sites, admins, project managers). Later we need to add
// Institutions as well and handle the messiness of addresses, countries, languages, phone numbers and other
// developer's nightmares. We think it's perhaps the best in the future to rely to external implementation for address
// management.
// On the other hand the implementation of contact (in order to allow to communicate with POLIS providers site admins)
// is simple enough task and therefore current implementation of POLIS includes contact-only related types.

/// `PolisCommunication` defines different types of communication channels in addition to the default email address and
/// mobile number.
///
/// The current list includes just a handful of popular communication channels. Emerging apps like Signal and Telegram
/// are not currently included, nor are local Chinese and Russian social media communication channels. If you need
/// such channels, please submit a pool request.
///
/// The type implements the `Codable` protocol
public enum PolisCommunication {

    /// Twitter user id, e.g. @AstroPolis "@" is expected to be part of the id
    case twitter(username: String)

    /// Phone number used by WhatsApp. The phone number should include the country code, start with "+", and contain no
    /// spaces, brackets, or other formatting characters. Currently no validation is provided.
    case whatsApp(phone: String)

    /// The Facebook user id is only the part of the URL after "www.facebook.com/".
    case facebook(id: String)

    /// Instagram user id, e.g. @AstroPolis "@" is expected to be part of the id
    case instagram(username: String)

    /// Skype user id
    case skype(id: String)
}

/// `PolisAdminContact` defines a simple way to contact a provider admin, an observing site owner, or an observatory
/// admin.
///
/// It is important to be able to contact the admin of a POLIS service provider or the admin or the owner of an
/// observing site, however one should not forget that all POLIS data is publicly available and therefore should not
/// expose private information if possible. It is preferred not to expose private email addresses, phone numbers, or
/// twitter accounts, but only publicly available organisation contacts.
///
/// The type implements the `Codable` protocol
public struct PolisAdminContact {

    /// It is recommended that the admin's name is either omitted, or describes admin's role, e.g. "The managing
    /// director of Mountain Observatory"
    public var name: String?

    /// Email is the most reliable and widely adopted communication channel, and therefore a valid email address is
    /// required. To protect privacy, it is recommended that the email address is assigned to the institution,
    /// e.g. "office@mountain-observatory.org". It is expected the email to be valid.
    public var email: String

    /// Consider giving only institution phone numbers - not private ones. The phone number should include the country
    /// code, starting with "+", and should contain no spaces, brackets, or other formatting characters. No validation
    /// is provided.
    public var mobilePhone: String?

    /// Possibly empty list (array) of additional communication channels of type ``Communicating``.
    public var additionalCommunicationChannels: [PolisCommunication]

    /// `notes` can contain additional contact info, e.g. "The admin could be contacted only during office hours"
    public var notes: String?

    /// Designated initialiser
    ///
    /// Only the `email` is a required parameter. It must contain well formatted email addresses. If the email is not a
    /// valid one, `nil` will be returned.
    public init?(name:                            String?,
                 email:                           String,
                 mobilePhone:                     String? = nil,
                 additionalCommunicationChannels: [PolisCommunication] = [PolisCommunication](),
                 notes:                           String?) {
        guard email.isValidEmailAddress() else { return nil }

        self.name                            = name
        self.email                           = email
        self.mobilePhone                     = mobilePhone
        self.additionalCommunicationChannels = additionalCommunicationChannels
        self.notes                           = notes
    }
}


//MARK: - Manufacturer information -

/// `PolisManufacturer` encapsulates basic information about manufacturer.
///
/// Every provider is free to implement it's own handling of list of manufacturers, but we highly recommend that all
/// manufacturer information is managed in a single, possibly manually maintained store. This will help client
/// application to display unique information.
/// Later implementation of POLIS might provide a common list of manufacturers.
public struct PolisManufacturer: Codable, Identifiable {
    /// Makes `PolisManufacturer` uniquely identifiable
    public var attributes: PolisItemAttributes

    /// The fully qualified URL of the service provider, e.g. https://www.celestron.com
    public var url: URL?

    /// The person (or email address) you can contact.
    public var contact: PolisAdminContact?

    /// `id` is needed to make the structure `Identifiable`
    public var id: UUID { attributes.id }
}

//MARK: - Ownership -

/// `PolisOwnershipType` defines various ownership types
///
/// `PolisOwnershipType` is used to identify the ownership type of POLIS items (or instruments) - observing sites,
/// telescopes, CCD cameras, weather stations, etc. Different cases should be self-explanatory. `private` should be
/// used by amateurs and hobbyists.
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
    case `private`
    case other
}


//MARK: - Making types Codable and CustomStringConvertible -
// These extensions do not need any additional documentation.


//MARK: - ContactType
extension PolisCommunication: Codable, CustomStringConvertible {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base      = try container.decode(CommunicationType.self, forKey: .communicationType)

        switch base {
            case .twitter:
                let twitterParams = try container.decodeIfPresent(TwitterParams.self, forKey: .twitterParams)
                self = .twitter(username: twitterParams!.username.mustStartWithAtSign())
            case .whatsApp:
                let whatsAppParams = try container.decodeIfPresent(WhatsAppParams.self, forKey: .whatsAppParams)
                self = .whatsApp(phone: whatsAppParams!.phone)
            case .facebook:
                let facebookParams = try container.decodeIfPresent(FacebookParams.self, forKey: .facebookParams)
                self = .facebook(id: facebookParams!.id)
            case .instagram:
                let instagramParams = try container.decodeIfPresent(InstagramParams.self, forKey: .instagramParams)
                self = .instagram(username: instagramParams!.username.mustStartWithAtSign())
            case .skype:
                let skypeParams = try container.decodeIfPresent(SkypeParams.self, forKey: .skypeParams)
                self = .skype(id: skypeParams!.id)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .twitter(let username):
                try container.encode(CommunicationType.twitter, forKey: .communicationType)
                try container.encode(TwitterParams(username: username), forKey: .twitterParams)
            case .whatsApp(let phone):
                try container.encode(CommunicationType.whatsApp, forKey: .communicationType)
                try container.encode(WhatsAppParams(phone: phone), forKey: .whatsAppParams)
            case .facebook(let id):
                try container.encode(CommunicationType.facebook, forKey: .communicationType)
                try container.encode(FacebookParams(id: id), forKey: .facebookParams)
            case .instagram(let username):
                try container.encode(CommunicationType.instagram, forKey: .communicationType)
                try container.encode(InstagramParams(username: username), forKey: .instagramParams)
            case .skype(let id):
                try container.encode(CommunicationType.skype, forKey: .communicationType)
                try container.encode(SkypeParams(id: id), forKey: .skypeParams)
        }
    }

    public enum CodingKeys: String, CodingKey {
        case communicationType = "communication_type"
        case twitterParams     = "twitter"
        case whatsAppParams    = "whatsapp"
        case facebookParams    = "facebook"
        case instagramParams   = "instagram"
        case skypeParams       = "skype"
        case username          = "user_name"
    }

    private enum CommunicationType: String, Codable { case twitter, whatsApp, facebook, instagram, skype }

    private struct TwitterParams: Codable   { let username: String }
    private struct WhatsAppParams: Codable  { let phone: String }
    private struct FacebookParams: Codable  { let id: String }
    private struct InstagramParams: Codable { let username: String }
    private struct SkypeParams: Codable     { let id: String }

    public var description: String {
        switch self {
            case .twitter(let username):   return "Twitter: \(username)"
            case .whatsApp(let phone):     return "WhatsApp: \(phone)"
            case .facebook(let id):        return "Facebook: \(id)"
            case .instagram(let username): return "Instagram: \(username)"
            case .skype(let id):           return "Skype: \(id)"
        }
    }
}

//MARK: - PolisContact
extension PolisAdminContact: Codable {
    public enum CodingKeys: String, CodingKey {
        case name
        case email
        case mobilePhone                     = "mobile_phone"
        case additionalCommunicationChannels = "additional_communication_channels"
        case notes
    }
}



