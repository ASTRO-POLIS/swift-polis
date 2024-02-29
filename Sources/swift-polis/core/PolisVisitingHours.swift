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
/// ``PolisObservingFacility``  and other objects could be visited, or the working hours of the personnel.
///
/// Some facilities might only be open during part of the year (e.g. because of difficult winter conditions) or may
/// only be visited during school vacations.
///
/// **Examples:**
/// - A very simple example only with a note
///  ```json
///{
///   "only_group_visits": false,
///   "note": "For group and individual visits, please call the observatory office every working day between 14:00h and 16:00h."
///}
///  ```
///
///  - Every Sunday, every month, every year
///  ```json
///{
///    "visiting_possibilities": [
///        {
///           "applicable_weekdays": ["Sunday"],
///           "is_repeating": true
///        },
///    ],
///    "only_group_visits": true,
///    "note": "Please call before visiting."
///}
///```
///
/// - In 2024 and 2025, between July and September, every Saturday between 14:00 and 16:00 (only for groups), and every Sunday between
 // 9:00 and 12:00 and between 14:00 and 17:00.
///```json
///{
///   "visiting_possibilities": [
///       {
///          "applicable_years": [2024, 2025],
///          "applicable_months": [7, 8, 9],
///          "applicable_weekdays": ["Saturday"],
///          "opening_period": [ { "from": "14:00", "to": "16:00" } ],
///          "only_group_visits": true,
///          "is_repeating": true
///       },
///       {
///          "applicable_years": [2024, 2025],
///          "applicable_months": [7, 8, 9],
///          "applicable_weekdays": ["Sunday"],
///          "opening_period": [ { "from": "09:00", "to": "12:00" }, { "from": "14:00", "to": "16:00" } ],
///          "only_group_visits": false,
///          "is_repeating": true
///       }
///   ],
///   "note": "By or after heavy rain, the road to the observatory could be closed. Check the weather forcast before planning your visit."
///}


public struct PolisVisitingHours: Codable {

    /// Simplified string that represents hours and minutes in the format `HH:mm`
    ///
    /// - Hours should be in the range of 0-23
    /// - Minutes should be in the range of 0-59
    ///
    /// **Note:** Later implementations may implement format checking by implementing a custom formatter.
    ///
    /// Examples:
    /// - `"00:15"`- 15 min after midnight
    /// - `"12:00"`- noon
    /// - `"20:00"` - 8pm in the evening
    public typealias HoursAndMinutes = String

    /// `VisitingPossibility` ...
    //TODO: Finish documentation!
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

        public var minVisitingGroupSize: Int?
        public var maxVisitingGroupSize: Int?
        public var onlyGroupVisits = false

        public var isRepeating = true
        public var note: String?

        public init(applicableYears: [Int]?             = nil,
                    applicableMonths: [Int]?            = nil,
                    applicableWeekdays: [DayOfTheWeek]? = nil,
                    openingPeriod: [TimePeriod]?        = nil,
                    minVisitingGroupSize: Int?          = nil,
                    maxVisitingGroupSize: Int?          = nil,
                    onlyGroupVisits: Bool               = false,
                    isRepeating: Bool                   = true,
                    note: String?                       = nil) {
            self.applicableYears      = applicableYears
            self.applicableMonths     = applicableMonths
            self.applicableWeekdays   = applicableWeekdays
            self.openingPeriod        = openingPeriod
            self.minVisitingGroupSize = minVisitingGroupSize
            self.maxVisitingGroupSize = maxVisitingGroupSize
            self.onlyGroupVisits      = onlyGroupVisits
            self.isRepeating          = isRepeating
            self.note                 = note
        }
  }

    public var visitingPossibilities: [VisitingPossibility]?

    public var note: String?

    public init(visitingPossibilities: [VisitingPossibility]? = nil,
                note: String?                                 = nil) {
        self.visitingPossibilities = visitingPossibilities
        self.note                  = note
    }}


//MARK: - Type extensions -



//MARK: - VisitingPossibility
public extension PolisVisitingHours.VisitingPossibility {
    enum CodingKeys: String, CodingKey {
        case applicableYears      = "applicable_years"
        case applicableMonths     = "applicable_months"
        case applicableWeekdays   = "applicable_weekdays"
        case openingPeriod        = "opening_period"
        case minVisitingGroupSize = "min_visiting_group_size"
        case maxVisitingGroupSize = "max_visiting_group_size"
        case onlyGroupVisits      = "only_group_visits"
        case isRepeating          = "is_repeating"
        case note
    }
}

//MARK: - PolisVisitingHours
public extension PolisVisitingHours {
    enum CodingKeys: String, CodingKey {
        case visitingPossibilities = "visiting_possibilities"
        case note
    }
}

