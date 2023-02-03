//
//  PolisTelescope.swift
//  
//
//  Created by Georg Tuparev on 3.02.23.
//

import Foundation

// Notes / Questions:
// - PolisTelescope does not need extra properties. All attributes should be defined here.
// - Do we need a list of references back to possible Networks?


/// `PolisTelescope` is an  instrument to observe astronomical objects composed by a hierarchy of devices arranged in possibly different configurations.
public struct PolisTelescope {

    public var item: PolisItem
    public var deviceIDs: Set<UUID> // Only the root devices of the hierarchy
    public var configurationIDs: Set<UUID>

    // We need some kind of reference to the enclosing observer site, but what about satellites and rovers?
}
