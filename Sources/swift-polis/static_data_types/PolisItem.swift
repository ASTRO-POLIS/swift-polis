//
//  PolisItem.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20.08.24.
//

import Foundation


public struct PolisItem: Codable, Equatable {

    public var identity: PolisIdentity
    public var owner: PolisOwner?

    public var parentID: UUID?

    public var automationLabel: String?

    public var mediaSourceID: UUID?

    public init(identity: PolisIdentity,
                owner: PolisOwner?       = nil,
                parentID: UUID?          = nil,
                automationLabel: String? = nil,
                mediaSourceID: UUID?     = nil) {
        self.identity                     = identity
        self.owner           = owner
        self.parentID        = parentID
        self.mediaSourceID   = mediaSourceID
    }

    public          func childrenIDs() -> Set<UUID> { _childrenIDs }
    public mutating func addChildWith(id: UUID)     { _childrenIDs.insert(id) }
    public mutating func removeChildWith(id: UUID)  { _childrenIDs.remove(id) }

    //MARK: - Private properties
    private var _childrenIDs = Set<UUID>()
}

public extension PolisItem {
    enum CodingKeys: String, CodingKey {
        case identity
        case owner
        case parentID        = "parent_id"
        case automationLabel = "automation_label"
        case mediaSourceID   = "media_source_id"
    }
}

