//
//  PolisUtilities.swift
//  swift-polis
//
//  Created by Georg Tuparev on 22/09/2024.
//

import Foundation

//MARK: - Support for References -

// These are several convenience global functions that work on POLIS references

/// Checks if the string is a valid POLIS reference
public func isPolisReference(_ candidate: String) -> Bool { candidate.hasPrefix(PolisConstants.polisReferencePrefix) && (uuidFromPolis(reference: candidate) != nil)}

/// Extracts UUID string from a valid POLIS reference
public func uuidFromPolis(reference: String) -> String? {
    guard let candidate = reference.components(separatedBy: "//").last else { return nil }
    if UUID(uuidString: candidate) == nil { return nil }
    return candidate
}

/// Creates a new POLIS reference from a valid UUID
public func polisReferenceFrom(uuid: UUID) -> String { "\(PolisConstants.polisReferencePrefix)\(uuid.uuidString)" }
