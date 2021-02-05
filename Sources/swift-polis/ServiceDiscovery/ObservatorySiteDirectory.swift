//
//  ObservatorySiteDirectory.swift
//  
//
//  Created by Georg Tuparev on 25/11/2020.
//

import Foundation

/// It is expected, that the list of observatory sites is long and each site's data could be way over 1MB. Therefore a
/// compact list of site references is maintained separately containing only site UUIDs and last update time. It is
/// recommended that clients cache this list and update the observatory data only in case the cache needs to be
/// invalidated (e.g. lastUpdate is changed).
/// 
/// **Note for Swift developers:** COURAGEOUS and IMPORTANT ASSUMPTION: Types defined in this file and in
/// `ServiceDiscovery.swift` should not have incompatible coding/decoding and API changes in future versions of the
/// standard! All other types could evolve.

public struct ObservatorySiteDirectory: Codable {
    public let lastUpdate: Date                   // UTC
    public let entries: [ObservingSiteReference]

    public init(lastUpdate: Date, entries: [ObservingSiteReference]) {
        self.lastUpdate = lastUpdate
        self.entries = entries
    }
}

/// This is only a quick reference to check if Client's cache has this site and if the site is up-to-date.
public struct ObservingSiteReference: Codable {
    public var attributes: PolisItemAttributes
    public let shortName: String?  // This is useful for testing during development

    public init(attributes: PolisItemAttributes, shortName: String?) {
        self.attributes = attributes
        self.shortName = shortName
    }
}
