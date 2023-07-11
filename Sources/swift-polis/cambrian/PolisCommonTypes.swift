//===----------------------------------------------------------------------===//
//  PolisCommonTypes.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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

/// The `PolisVisitingHours` struct is used to define periods of time when an ``PolisObservingSite`` could be visited, or the working hours of the personnel.
///
/// Note that some sites might only be open during part of the year (e.g. because of difficult winter conditions) or may only be visited during school vacations.
///
/// The first version of the the POLIS standard defines only an optional `note` string.  Future versions will add more structured types expressing numerical periods like:
///    Mo-Fr: 16:00-18:00h or
///    June - September
/// Currently this more natural representation could be achieved by formatting `note` using `\n` (new lines) and tabs.
public struct PolisVisitingHours: Codable {
    public var note: String?

    public init(note: String? = nil) {
        self.note = note
    }
}

//MARK: - Property Values -
// Basic idea - value is always a string that is converted (if possible) to a typed value.
/// An object that represents a value a value with an accompanying unit.
///
/// Examples include telescope apertures, instrument wavelengths, etc. POLIS only defines the means of recording measurements. Client applications using POLIS
/// should implement unit conversions (if needed). Currently, a POLIS provider is not expected to make any conversions, but it might check if the units are allowed.
///
/// Apple's Units types are not used here on purpose because of the lack of scientific accuracy and profound misunderstanding of how science works.
///
/// **Note:** This Measurement implementation is very rudimentary. It is a placeholder type. In future implementations, it will be replaced by external
/// implementations, capable of measurement computations and conversions.
public struct PolisPropertyValue: Codable, Equatable {

    public enum ValueKind: String, Codable {
        case string
        case int
        case float
        case double
    }

    //TODO: Make this Equitable and String CustomStringConvertible!

    public var valueKind: ValueKind

    /// The value of the measurement represented as a `String`
    public var value: String

    /// Unit of the measurement.
    ///
    /// The unit is expected to be in a format that is accepted by the astronomical community (as defined by the IAU, FITS Standard, etc).
    ///
    /// In the case that no unit is defined, the measurement has no dimension (e.g. counter).
    ///
    /// Examples:
    /// - "m"
    /// - "km"
    /// - "in"
    /// - "m^2"
    /// - "µm"
    /// - "solMass"
    /// - "eV"
    public var unit: String

    public init(valueKind: ValueKind, value: String,  unit: String) {
        self.valueKind  = valueKind
        self.value      = value
        self.unit       = unit
    }

    public func stringValue()  -> String? { value }
    public func intValue()     -> Int?    { Int(value) }
    public func floatValue()   -> Float?  { Float(value) }
    public func doubleValue()  -> Double? { Double(value) }

}

//MARK: - Directions -

/// `PolisDirection` is used to represent either a rough direction (of 16 possibilities) or exact direction in degree
/// represented as a double number (e.g. 57.349)
///
/// Directions are used to describe information such as dominant wind direction of observing site, or direction of doors of
/// different types of enclosures.
public struct PolisDirection: Codable {

    /// A list of 16 rough directions.
    ///
    /// These 16 directions are comprised of the 4 cardinal directions (north, east, south, west), the 4
    /// ordinal (also known as inter-cardinal) directions (northeast, northwest, southeast, southwest), and
    /// the 8 additional secondary inter cardinal directions (ex. ENE, SSW, WSW).
    ///
    /// Rough direction could be used when it is not important to know or impossible to measure the exact direction.
    /// Examples include the wind direction, or the orientations of the doors of a clamshell enclosure.
    public enum RoughDirection: String, Codable {
        case north          = "N"
        case northNorthEast = "NNE"
        case northEast      = "NE"
        case eastNorthEast  = "ENE"

        case east           = "E"
        case eastSouthEast  = "ESE"
        case southEast      = "SE"
        case southSouthEast = "SSE"

        case south          = "S"
        case southSouthWest = "SSW"
        case southWest      = "SW"
        case westSouthWest  = "WSW"

        case west           = "W"
        case westNorthWest  = "WNW"
        case northWest      = "NW"
        case northNorthWest = "NNW"

        public func direction() -> Double {
            switch self {
                case .north:          return 0.0
                case .northNorthEast: return 22.5
                case .northEast:      return 45.0
                case .eastNorthEast:  return 67.5
                case .east:           return 90.0
                case .eastSouthEast:  return 112.5
                case .southEast:      return 135.0
                case .southSouthEast: return 157.5
                case .south:          return 180.0
                case .southSouthWest: return 202.5
                case .southWest:      return 225.0
                case .westSouthWest:  return 247.5
                case .west:           return 270.0
                case .westNorthWest:  return 292.5
                case .northWest:      return 315.0
                case .northNorthWest: return 337.5
            }
        }
    }

    public enum DirectionError: Error {
        case bothPropertiesCannotBeNilError
        case bothPropertiesCannotBeNotNilError
    }

    public var roughDirection: RoughDirection? {
        didSet {
            if roughDirection != nil                              { exactDirection = nil }
            if (roughDirection == nil) && (exactDirection == nil) { roughDirection = oldValue }
        }
    }

    public var exactDirection: Double? {  // Clockwise e.g. 157.12
        didSet {
            if exactDirection != nil                              { roughDirection = nil }
            if (exactDirection == nil) && (roughDirection == nil) { exactDirection = oldValue }
        }
    }

    public init(roughDirection: RoughDirection? = nil, exactDirection: Double? = nil) throws {
        if (roughDirection == nil) && (exactDirection == nil) { throw DirectionError.bothPropertiesCannotBeNilError }
        if (roughDirection != nil) && (exactDirection != nil) { throw DirectionError.bothPropertiesCannotBeNotNilError }

        self.roughDirection = roughDirection
        self.exactDirection = exactDirection
    }

    // Clockwise e.g. 157.12
    public func direction() -> Double {
        if exactDirection != nil { return exactDirection! }
        else                     { return roughDirection!.direction() }
    }
}

//MARK: - Type extensions -
public extension PolisPropertyValue {
    enum CodingKeys: String, CodingKey {
        case valueKind = "value_kind"
        case value
        case unit
    }
}

public extension PolisDirection {
    enum CodingKeys: String, CodingKey {
        case roughDirection = "rough_direction"
        case exactDirection = "exact_direction"
    }
}
