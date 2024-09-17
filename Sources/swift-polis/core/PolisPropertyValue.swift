//===----------------------------------------------------------------------===//
//  PolisPropertyValue.swift
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

// Basic idea - value is always a JSON string that is converted (if possible) to a typed value.

/// A type that represents a value and a unit.
///
/// Examples include telescope apertures, instrument wavelengths, etc. POLIS only defines the means of 
/// recording measurements. Client applications using POLIS should implement unit conversions (if needed).
/// Currently a POLIS provider is not expected to implement any unit conversions, but it might check if the
/// units are allowed.
///
    /// Apple's Units types are purposely not used here because of the lack of scientific accuracy and profound
    /// misunderstanding of how science works. In addition, they are not platform-independent.
///
/// **Note:** This Measurement implementation is very rudimentary. It is a placeholder type. In future 
/// implementations, it will be replaced by external implementations, capable of measurement computations
/// and conversions.
public struct PolisPropertyValue: Codable, Equatable {

    public enum ValueKind: String, Codable {
        case string
        case int
        case float
        case double
    }

    /// The expected value kind
    public var valueKind: ValueKind

    /// The value of the measurement represented as a `String`
    ///
    /// To simplify the standard, all values are stored in string. It is implementation's
    /// responsibility to convert the string value into a proper programming language
    /// supported type , e.g. `Int`, `Double`, ...
        public var value: String

    /// Unit of the measurement.
    ///
    /// The unit is expected to be in a format that is accepted by the astronomical community (as defined 
    /// by the IAU, FITS Standard, etc). POLIS will provide a list of standard units that are widely used in
    /// FITS files as well as approved by the IAU. Future version of this framework may implement
    /// automatic checks for units.
    ///
    /// In the case that no unit is defined, the measurement has no dimension (e.g. counter).
    ///
    /// Examples for measurements with units:
    /// - "m"
    /// - "km"
    /// - "in"
    /// - "m^2"
    /// - "µm"
    /// - "solMass"
    /// - "eV"
    public var unit: String?

    /// Designated initialiser
    ///
    /// In case `unit` is `nil`, it is assumed that the value is of type counter, e.g. number of mirror in OTA.
    public init(valueKind: ValueKind, value: String,  unit: String? = nil) {
        self.valueKind = valueKind
        self.value     = value
        self.unit      = unit
    }

    /// Returns a `String` value if the `valueKind` is equal to`.string`
    public func stringValue() -> String? {
        if valueKind != .string { return nil }
        else                    { return value }
    }

    /// Returns an `Int` value if the `valueKind` is is equal  `.int`
    public func intValue() -> Int? {
        if valueKind != .int { return nil }
        else                 { return Int(value) }
    }

    /// Returns a `Float` value if the `valueKind` is is equal  `.float`
    public func floatValue() -> Float? {
        if valueKind != .float { return nil }
        else                   { return Float(value) }
    }

    /// Returns a `Double` value if the `valueKind` is is equal  `.double`
    public func doubleValue() -> Double? {
        if valueKind != .double { return nil }
        else                    { return Double(value) }
    }
}

//MARK: - Property Value
public extension PolisPropertyValue {
    enum CodingKeys: String, CodingKey {
        case valueKind = "value_kind"
        case value
        case unit
    }
}
