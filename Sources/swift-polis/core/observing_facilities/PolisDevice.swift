//
//  PolisDevice.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/11/2024.
//

import Foundation

public struct PolisDevice: Codable, Identifiable {

    public var identity: PolisIdentity
    public var propertiesID: UUID?
    public var childIDs: Set<UUID>?

    public var containsDynamicChildren: Bool
    public var isDynamic: Bool

    public var id: UUID { identity.id }

}

public extension PolisDevice {
    enum CodingKeys: String, CodingKey {
        case identity
        case propertiesID            = "properties_id"
        case childIDs                = "child_ids"
        case containsDynamicChildren = "contains_dynamic_children"
        case isDynamic               = "is_dynamic"
    }
}
