//
//  PolisManufacturer.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.09.24.
//

import Foundation

/// A type that encapsulates basic information about the manufacturer.
///
/// Every provider is free to implement it's own handling of lists of manufacturers, but we highly recommend that all manufacturer information is managed in a single,
/// possibly manually maintained, cache. This will help client applications to display unique information and avoid "almost the same" information being found multiple
/// times. It is preferable and better for the community as a whole if manufacturers maintain their product catalogues themselves.
///
/// It is important that POLIS Providers guarantee the uniqueness of manufacturers and their products. This is not required by the standard, but it is strongly
/// recommended and makes the experience better for everyone.
public struct PolisManufacturer: Codable, Identifiable {
    /// Makes `PolisManufacturer` uniquely identifiable.
    public var identity: PolisIdentity

    public var id: UUID { identity.id }

    /// The fully qualified URL of the service provider, e.g. https://www.celestron.com
    public var url: URL?

    /// The point-of-contact for the manufacturer.
    public var adminContact: PolisAdminContact?

    public var addresses: [PolisAddress]?

    public var communication: PolisCommunicationChannel?

    public init(identity: PolisIdentity,
                url: URL?                                 = nil,
                adminContact: PolisAdminContact?          = nil,
                addresses: [PolisAddress]?                = nil,
                communication: PolisCommunicationChannel? = nil) {
        self.identity      = identity
        self.url           = url
        self.adminContact  = adminContact
        self.addresses     = addresses
        self.communication = communication
    }
}

//MARK: - Manufacturer information
extension PolisManufacturer {
    enum CodingKeys: String, CodingKey {
        case identity
        case url
        case adminContact = "admin_contact"
        case addresses
        case communication
    }
}
