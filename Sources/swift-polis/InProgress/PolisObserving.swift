//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//


import Foundation

public enum PolisObservingType: String, Codable {
    case site
    case mobilePlatform
    case collaboration
    case network
    case array
}

public protocol PolisObserving: Codable, Identifiable {
    var type: PolisObservingType          { get }
    var item: PolisItem                   { get set }
    var parentID: UUID?                   { get set }
    var deviceIDs: [UUID]                 { get set }
    var configurationIDs: [UUID]          { get set }
    var location: PolisObservingLocation? { get set }
    var startDate: Date?                  { get set } // Could be nil if unknown
    var endDate: Date?                    { get set } // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
    var admins: [PolisAdminContact]?      { get set }
}

public struct PolisObservingSite: PolisObserving {
    public var type                              = PolisObservingType.site
    public var item: PolisItem
    public var parentID: UUID?
    public var deviceIDs                         = [UUID]()
    public var configurationIDs                  = [UUID]()
    public var location: PolisObservingLocation?
    public var startDate: Date?
    public var endDate: Date?
    public var admins: [PolisAdminContact]?

    public var id: UUID { item.identity.id }
}


//MARK: - Type extensions -



//MARK: - Observing Site
public extension PolisObservingSite {
    enum CodingKeys: String, CodingKey {
        case type
        case item
        case parentID         = "parent_id"
        case deviceIDs        = "device_ids"
        case configurationIDs = "configuration_ids"
        case location
        case startDate        = "start_date"
        case endDate          = "end_date"
        case admins
    }
}
