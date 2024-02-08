//===----------------------------------------------------------------------===//
//  PolisDirection.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2024 Tuparev Technologies and the ASTRO-POLIS project
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

/// `PolisDirection` is used to represent either a rough direction (one of 16 possibilities) or exact direction 
/// in degree represented as a double number (e.g. clockwise 157.12)
///
/// Directions are used to describe information such as dominant wind direction of observing facilities, or 
/// direction of doors of different types of enclosures.
public struct PolisDirection: Codable {

    /// `RoughDirection` - a list of 16 rough directions.
    ///
    /// These 16 directions are comprised of the 4 cardinal directions (north, east, south, west), the 4
    /// ordinal (also known as inter-cardinal) directions (northeast, northwest, southeast, southwest), and
    /// the 8 additional secondary inter cardinal directions (ex. ENE, SSW, WSW).
    ///
    /// Rough direction could be used when it is not important to know or impossible to measure the exact
    /// direction. Examples include the wind direction, or the orientations of the doors of a clamshell enclosure.
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

    /// Possible errors id a `PolisDirection` cannot be created.
    ///
    /// While creating a direction, one and only one of the `roughDirection` or `exactDirection` shall
    /// be defined.
    public enum DirectionError: Error {
        case bothPropertiesCannotBeNilError
        case bothPropertiesCannotBeNotNilError
    }

    /// Designated initialiser.
    ///
    /// See ``DirectionError`` for possible errors during creation
    public init(roughDirection: RoughDirection? = nil, exactDirection: Double? = nil) throws {
        if (roughDirection == nil) && (exactDirection == nil) { throw DirectionError.bothPropertiesCannotBeNilError }
        if (roughDirection != nil) && (exactDirection != nil) { throw DirectionError.bothPropertiesCannotBeNotNilError }

        //TODO: Make sure that exactDirection <= 360.0!
        self.roughDirection = roughDirection
        self.exactDirection = exactDirection
    }

    // Clockwise e.g. 157.12
    public func direction() -> Double {
        if exactDirection != nil { return exactDirection! }
        else                     { return roughDirection!.direction() }
    }

    //MARK: - Private stuff
    private var roughDirection: RoughDirection?
    private var exactDirection: Double?
}

//MARK: - Type extensions -

//MARK: - Directions
public extension PolisDirection {
    enum CodingKeys: String, CodingKey {
        case roughDirection = "rough_direction"
        case exactDirection = "exact_direction"
    }
}

