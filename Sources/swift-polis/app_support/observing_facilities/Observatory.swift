//
//  Observatory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation

public actor Observatory: @preconcurrency Persisting {

    public var identifiableObject: IdentifiableObject
    public var id                : UUID { identifiableObject.id }

    init(identifiableObject: IdentifiableObject) {
        self.identifiableObject = identifiableObject
    }
}
