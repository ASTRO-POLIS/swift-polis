//===----------------------------------------------------------------------===//
//  PolisVisitingHours.swift
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

/// The `PolisVisitingHours` struct is used to define periods of time when a 
/// ``PolisObservingFacility``,  and other types could be visited, or the working hours of the personnel.
///
/// Some facilities might only be open during part of the year (e.g. because of difficult winter conditions) or may
/// only be visited during school vacations.
public struct PolisVisitingHours: Codable {

    public typealias HoursAndMinutes = String

    public struct VisitingPossibility: Codable {


        public enum DayOfTheWeek: String, Codable {
            case monday    = "Monday"
            case tuesday   = "Tuesday"
            case wednesday = "Wednesday"
            case thursday  = "Thursday"
            case friday    = "Friday"
            case saturday  = "Saturday"
            case sunday    = "Sunday"
        }

        public struct TimePeriod: Codable {
            public var from: HoursAndMinutes
            public var to: HoursAndMinutes

            public init(from: HoursAndMinutes, to: HoursAndMinutes) {
                self.from = from
                self.to   = to
            }
        }

        public var applicableYears: [Int]?
        public var applicableMonths: [Int]?
        public var applicableWeekdays: [DayOfTheWeek]?
        public var openingPeriod: [TimePeriod]?

        public var isRepeating = true
        public var note: String?

        public init(applicableYears: [Int]?              = nil, 
                    applicableMonths: [Int]?             = nil,
                    applicableWeekdays: [DayOfTheWeek]?  = nil,
                    openingPeriod: [TimePeriod]?         = nil,
                    isRepeating: Bool                    = true,
                    note: String?                        = nil) {
            self.applicableYears    = applicableYears
            self.applicableMonths   = applicableMonths
            self.applicableWeekdays = applicableWeekdays
            self.openingPeriod      = openingPeriod
            self.isRepeating        = isRepeating
            self.note               = note
        }
  }

    public var visitingPossibilities: [VisitingPossibility]?

    public var minVisitingGroupSize: Int?
    public var maxVisitingGroupSize: Int?
    public var onlyGroupVisits: Bool

    public var note: String?

    public init(visitingPossibilities: [VisitingPossibility]?  = nil, 
                minVisitingGroupSize: Int?                     = nil,
                maxVisitingGroupSize: Int?                     = nil,
                onlyGroupVisits: Bool                          = false,
                note: String?                                  = nil) {
        self.visitingPossibilities = visitingPossibilities
        self.minVisitingGroupSize  = minVisitingGroupSize
        self.maxVisitingGroupSize  = maxVisitingGroupSize
        self.onlyGroupVisits       = onlyGroupVisits
        self.note                  = note
    }}


//MARK: - Type extensions -



//MARK: - VisitingPossibility
public extension PolisVisitingHours.VisitingPossibility {
    enum CodingKeys: String, CodingKey {
        case applicableYears    = "applicable_years"
        case applicableMonths   = "applicable_months"
        case applicableWeekdays = "applicable_weekdays"
        case openingPeriod      = "opening_period"
        case isRepeating        = "is_repeating"
        case note
    }
}

//MARK: - PolisVisitingHours
public extension PolisVisitingHours {
    enum CodingKeys: String, CodingKey {
        case visitingPossibilities = "visiting_possibilities"
        case minVisitingGroupSize  = "min_visiting_group_size"
        case maxVisitingGroupSize  = "max_visiting_group_size"
        case onlyGroupVisits       = "only_group_visits"
        case note
    }
}

