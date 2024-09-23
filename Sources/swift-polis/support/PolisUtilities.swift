//
//  PolisUtilities.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/09/2024.
//

import Foundation

//MARK: - Support for References -

public func isPolisReference(_ candidate: String) -> Bool { candidate.hasPrefix(PolisConstants.polisReferencePrefix) && (uuidFromPolis(reference: candidate) != nil)}

public func uuidFromPolis(reference: String) -> String? {
    guard let candidate = reference.components(separatedBy: "//").last else { return nil }
    if UUID(uuidString: candidate) == nil { return nil }
    return candidate
}
