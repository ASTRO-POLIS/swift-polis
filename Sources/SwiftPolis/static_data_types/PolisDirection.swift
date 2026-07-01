//===----------------------------------------------------------------------===//
//  PolisDirection.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2026 Tuparev Technologies and the ASTRO-POLIS project
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

/// Directions are used to describe information such as dominant wind direction of observing facilities, or
/// direction of doors of different types of enclosures.
/// A value type representing a direction either as a rough compass point or an exact bearing in degrees.
///
/// PolisDirection encapsulates two complementary ways of expressing a heading:
/// - RoughDirection: a discrete 16-point compass rose (e.g., N, NE, WSW) useful when approximate direction suffices.
/// - Exact direction: a clockwise bearing in degrees as a Double within the normalised range [0, 360).
///
/// Typical uses include describing environmental or mechanical orientations, such as:
/// - Dominant wind direction at an observing site
/// - Door or slit orientation for different enclosure types
///
/// Features:
/// - Codable: Encodes/decodes using snake_case keys "rough_direction" and "exact_direction".
/// - Equatable: Supports direct equality comparison.
/// - Sendable: Safe for concurrent use across tasks/threads.
///
/// Construction:
/// - init(roughDirection: RoughDirection): Creates an instance from a 16-point compass direction.
/// - init(exactDirection: Double): Creates an instance from a bearing in degrees; values are normalised into [0, 360).
///
/// Behavior:
/// - direction(): Returns the bearing in degrees. If an exact direction is set, it is returned; otherwise the
///   canonical degree value for the rough direction is returned.
/// - nearestRoughDirection(): Returns the closest RoughDirection. If an exact direction is set, it is mapped to the
///   nearest 16-point compass direction; otherwise the stored rough direction is returned.
///
/// Notes:
/// - When initialised with an exact direction, negative or >360° inputs are normalised by modulo 360 into [0, 360).
/// - Only one of roughDirection or exactDirection is typically set at a time; accessors handle choosing the
///   appropriate representation transparently.
public struct PolisDirection: Codable, Equatable, Sendable {

    /// Rough direction could be used when it is not important to know or impossible to measure the exact
    /// direction. Examples include the wind direction, or the orientations of the doors of a clamshell enclosure.
    /// A 16-point compass rose representing rough (approximate) directions.
    ///
    /// RoughDirection provides a human-friendly, discrete set of headings commonly sed in navigation and environmental
    /// descriptions when exact precision is not required or not available.
    /// These include:
    /// - The 4 cardinal directions: N, E, S, W
    /// - The 4 inter-cardinal (ordinal) directions: NE, SE, SW, NW
    /// - The 8 secondary inter-cardinal directions: NNE, ENE, ESE, SSE, SSW, WSW, WNW, NNW
    ///
    /// Each case has an associated raw value string using a standard abbreviated compass notation (e.g., "N", "SW",
    /// "ENE") and maps to a canonical clockwise bearing in degrees where:
    /// - 0° corresponds to North
    /// - 90° corresponds to East
    /// - 180° corresponds to South
    /// - 270° corresponds to West
    /// - Secondary points are spaced at 22.5° increments between these.
    ///
    /// Conformance:
    /// - Codable: Encodes/decodes using the raw string abbreviation (e.g., "WNW").
    /// - CaseIterable: Iterate over all 16 compass points in increasing clockwise order when paired with `direction()`.
    /// - Identifiable: Uses `self` as a stable identity, suitable for SwiftUI lists.
    /// - Equatable: Compare directions directly for equality.
    /// - Sendable: Safe to use across concurrency boundaries.
    ///
    /// Usage notes:
    /// - Use `direction()` to obtain the canonical bearing in degrees for a given rough direction.
    /// - Use `abbreviation()` to obtain a display-friendly form that inserts a slash after the first character for
    ///   multi-letter abbreviations (e.g., "N/NE") to improve readability in UI contexts where desired.
    public enum RoughDirection: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {
        public var id: Self {
            return self
        }

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

        public func abbreviation() -> String {
            var result = self.rawValue

            if result.count > 1 { result.insert("/", at: result.index(result.startIndex, offsetBy: 1)) }
            
           return result
        }
    }

    public init(roughDirection: RoughDirection) { self.roughDirection = roughDirection }

    public init(exactDirection: Double) {
        // Normalise into [0, 360)
        var normalised = exactDirection.truncatingRemainder(dividingBy: 360.0)
        if normalised < 0 { normalised += 360.0 }
        self.exactDirection = normalised
    }

    // Clockwise e.g. 157.12
    public func direction() -> Double {
        if exactDirection != nil { return exactDirection! }
        else                     { return roughDirection!.direction() }
    }

    public func nearestRoughDirection() -> RoughDirection {
        if let exact = exactDirection { return PolisDirection.roughDirection(from: exact) }
        else                          { return roughDirection! }
    }
    
    public private(set) var roughDirection: RoughDirection?
    public private(set) var exactDirection: Double?

    //MARK: - Private stuff
    private static func roughDirection(from degree: Double) -> RoughDirection {
        if      degree < 22.5  { return .north }
        else if degree < 45.0  { return .northNorthEast }
        else if degree < 67.5  { return .eastNorthEast }

        else if degree < 90.0  { return .east }
        else if degree < 112.5 { return .eastSouthEast }
        else if degree < 135.0 { return .southEast }
        else if degree < 157.5 { return .southSouthEast }

        else if degree < 180.0 { return .south }
        else if degree < 202.5 { return .southSouthWest }
        else if degree < 225.0 { return .southWest }
        else if degree < 247.5 { return .westSouthWest }

        else if degree < 270.0 { return .west }
        else if degree < 292.5 { return .westNorthWest }
        else if degree < 315.0 { return .northWest }
        else                   { return .northNorthWest }
    }
}

//MARK: - Type extensions -

//MARK: - Directions
public extension PolisDirection {
    enum CodingKeys: String, CodingKey {
        case roughDirection = "rough_direction"
        case exactDirection = "exact_direction"
    }
}
