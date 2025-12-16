//
//  Device.swift
//  swift-polis
//
//  Created by Georg Tuparev on 14.05.25.
//

import Foundation

public actor Device: @preconcurrency Persisting {

    public var identifiableObject: IdentifiableObject
    public var id                : UUID { identifiableObject.identity.id }

    init(identifiableObject: IdentifiableObject) {
        self.identifiableObject = identifiableObject
    }
}
