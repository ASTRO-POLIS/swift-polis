//
//  PolisDevice.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/11/2024.
//

import Foundation

public struct PolisDevice: Codable, Identifiable, Equatable, Sendable {

    public var item: PolisItem

    public var deviceType: String
    public var deviceSpecificPropertiesID: UUID?

    public var manufacturer: UUID?
    
    public var containsDynamicChildren: Bool
    public var isDynamic: Bool

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with a given label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String?

    public var scientificObjectives: String?
    public var notes: String?

    public var id: UUID { item.identity.id }

    public init(item: PolisItem,
                deviceType: String,
                deviceSpecificPropertiesID: UUID? = nil,
                manufacturer: UUID?               = nil,
                containsDynamicChildren: Bool     = false,
                isDynamic: Bool                   = false,
                automationLabel: String?          = nil,
                scientificObjectives: String?     = nil,
                notes: String?                    = nil) {
        self.item                       = item
        self.deviceType                 = deviceType
        self.deviceSpecificPropertiesID = deviceSpecificPropertiesID
        self.manufacturer               = manufacturer
        self.containsDynamicChildren    = containsDynamicChildren
        self.isDynamic                  = isDynamic
        self.automationLabel            = automationLabel
        self.scientificObjectives       = scientificObjectives
        self.notes                      = notes
    }
}

public extension PolisDevice {
    enum CodingKeys: String, CodingKey {
        case item
        case deviceType                 = "device_type"
        case deviceSpecificPropertiesID = "device_specific_properties_id"
        case manufacturer
        case containsDynamicChildren    = "contains_dynamic_children"
        case isDynamic                  = "is_dynamic"
        case automationLabel            = "automation_label"
        case scientificObjectives       = "scientific_objectives"
        case notes
    }
}
