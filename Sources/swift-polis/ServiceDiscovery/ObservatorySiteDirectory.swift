//
//  ObservatorySiteDirectory.swift
//  
//
//  Created by Georg Tuparev on 25/11/2020.
//

import Foundation

/// It is expected, that the list of observatory sites is long and each site's data could be way over 1MB. Therefore a
/// list of site references is maintained separately containing only site UUIDs and last update time. It assumed that
/// clients cache this list and update the observatory data only in case the cache needs to be invalidated (e.g. lastUpdate
/// is changed.

public struct ObservatorySiteDirectory {
    public let lastUpdate: Date
    public let entries: [ObservingSiteReference]
}

/// This is only a quick reference to check if Client's cache has this site and if the site is up-to-date.
public struct ObservingSiteReference {
    public let uid: String       // Globally unique ID (UUID version 4)
    public let lastUpdate: Date
}
