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

    /// This is only a quick reference to check if Client's cache has this site and if the site is up-to-date.
public struct ObservingSiteReference: Codable, Identifiable {
    public var attributes: PolisItemAttributes
    
    public var id: UUID { attributes.id }
    
        //TODO: Add site type and coordinates!
    public init(attributes: PolisItemAttributes) {
        self.attributes = attributes
    }
}

public struct ObservatorySiteDirectory: Codable {
    public var lastUpdate: Date                   // UTC
    public var entries: [ObservingSiteReference]
    
    public init(lastUpdate: Date, entries: [ObservingSiteReference]) {
        self.lastUpdate = lastUpdate
        self.entries    = entries
    }
}

