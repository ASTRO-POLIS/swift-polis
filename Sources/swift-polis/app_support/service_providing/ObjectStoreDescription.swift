//
//  ObjectStoreDescription.swift
//  swift-polis
//
//  Created by Georg Tuparev on 4.02.26.
//

import Foundation

public struct ObjectStoreDescription: Sendable {

    public enum PathAccessibilityStatus: String, Sendable {
        case unknown                         = "Unknown"
        case unset                           = "Unset"
        case set                             = "Set"
        case unaccessible                    = "Unaccessible"
        case accessible                      = "Accessible"
        case accessibleWrongFormat           = "Accessible Wrong Format"            // Applies only to files
        case accessibleAndCorrectlyFormatted = "Accessible And Correctly Formatted" // Applies only to files
    }

    public internal(set) var status: ObjectStoreStatusType

    // Root path is the path leading to the path containing all POLIS data
    public internal(set) var rootPathAccessibilityStatus = PathAccessibilityStatus.unknown
    public internal(set) var rootPath: String?

    public internal(set) var polisFoldersAccessibilityStatus = PathAccessibilityStatus.unknown
    public internal(set) var polisFilesAccessibilityStatus   = PathAccessibilityStatus.unknown
    public internal(set) var polisFileResourceFinderStatus   = PathAccessibilityStatus.unknown

    //MARK: Internal APIs
    init(status: ObjectStoreStatusType = ObjectStoreStatusType.notConfigured) {
        self.status = status
    }

    mutating func setStatus(_ status: ObjectStoreStatusType) { self.status = status }

    mutating func setRootPathAccessibilityStatus(_ status: PathAccessibilityStatus) { rootPathAccessibilityStatus = status }
    mutating func setRootPath(_ path: String)                                       { rootPath = path }

    mutating func setPolisFoldersAccessibilityStatus(_ status: PathAccessibilityStatus) { polisFoldersAccessibilityStatus = status }
    mutating func setPolisFilesAccessibilityStatus(_ status: PathAccessibilityStatus)   { polisFilesAccessibilityStatus   = status }
    mutating func setPolisFileResourceFinderStatus(_ status: PathAccessibilityStatus)   { polisFileResourceFinderStatus   = status }
}
