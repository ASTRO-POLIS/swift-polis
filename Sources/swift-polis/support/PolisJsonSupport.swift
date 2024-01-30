//===----------------------------------------------------------------------===//
//  PolisJsonSupport.swift
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

// These are simple subclasses of the system provided JSON Decoder and Encoder
// that require the dates to be in ISO8601 format and produce well formatted
// and human readable JSON outputs.

/// An extension of `JSONDecoder` that adds ISO8601 date conformance.
///
///  Modern astronomy software packages use ISO8601 dates (e.g. latest versions of the FITS standard).
///  Therefore `POLIS` requires that all dates are in ISO8601 format.
public class PolisJSONDecoder: JSONDecoder {
    
    /// Ensures that dates are in ISO8601 format
    public override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date       = polisDateFormatter.date(from: dateString)

            if let date = date { return date }
            else               { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date values must be ISO8601 formatted") }
        }
    }
}

/// An extension of `JSONEncoder` that adds ISO8601 date conformance and produces human readable
/// JSON files.
public class PolisJSONEncoder: JSONEncoder {
    
    /// Ensures that dates are in ISO8601 format and the JSON files are human readable
    public override init() {
        super.init()

        self.dateEncodingStrategy = .iso8601
        self.outputFormatting     = .prettyPrinted
    }
}

/// This date formatter should be used for all POLIS dates
let polisDateFormatter = ISO8601DateFormatter()

