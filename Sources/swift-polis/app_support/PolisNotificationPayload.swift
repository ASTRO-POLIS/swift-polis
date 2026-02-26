//
//  PolisNotificationPayload.swift
//  swift-polis
//
//  Created by Zhanna Hakobyan on 26.02.26.
//

import Foundation

public struct PolisNotificationPayload: Hashable, Sendable {

    public enum Action: Sendable {
        case create, update, delete, load
    }

    public enum Entity: Sendable {
        case facility, artifact
    }

    public let action: Action
    public let entity: Entity
    public let id    : UUID
}
