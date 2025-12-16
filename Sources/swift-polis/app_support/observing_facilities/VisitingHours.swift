//
//  VisitingHours.swift
//  swift-polis
//
//  Created by Georg Tuparev on 30.05.25.
//

import Foundation

public actor VisitingHours: @preconcurrency Persisting, Sendable {

    public var identifiableObject: IdentifiableObject
    public var id                : UUID { identifiableObject.identity.id }

    init(identifiableObject: IdentifiableObject) {
        self.identifiableObject = identifiableObject
    }
}
