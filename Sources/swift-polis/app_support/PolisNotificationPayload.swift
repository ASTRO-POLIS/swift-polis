//
//  PolisNotificationPayload.swift
//  swift-polis
//
//  Created by Zhanna Hakobyan on 26.02.26.
//

import Foundation

struct PolisNotificationPayload: Hashable {

    enum ActionType {
        case sync
        case load
        case create
        case update
        case delete
    }

    let entity: PolisObjectType
    let actionType: ActionType
    let id: UUID

    init(entity: PolisObjectType, actionType: ActionType, id: UUID) {
        self.entity     = entity
        self.actionType = actionType
        self.id         = id
    }
}
