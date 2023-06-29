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
