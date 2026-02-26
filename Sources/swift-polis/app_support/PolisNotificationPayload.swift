//
//  PolisNotificationPayload.swift
//  swift-polis
//
//  Created by Zhanna Hakobyan on 26.02.26.
//

import Foundation

public struct PolisNotificationPayload: Hashable {

    public enum Action {
        case create, update, delete, load
    }

    public let entity: PolisObjectType
    public let action: Action
    public let id    : UUID
}
