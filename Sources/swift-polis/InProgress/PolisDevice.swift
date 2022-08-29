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

public struct PolisDevice {

    public enum Types: String, Codable {

        //TODO: Sort them logically!

        case telescope         = "Telescope"
        case mount             = "Mount"
        case ota               = "OTA"
        case enclosure         = "Enclosure"
        case mirror            = "Mirror"
        case camera            = "Camera"
        case shutter           = "Sutter"
        case detector          = "Detector"
        case sensor            = "Sensor"
        case spectrograph      = "Spectrograph"
        case grating           = "Grating"
        case filterWheel       = "FilterWheel"
        case filter            = "Filter"
        case eyePiece          = "EyePiece"
        case derotator         = "Derotator"
        case weatherStation    = "WeatherStation"
        case ups               = "UPS"
        case webcam            = "Webcam"
        case skyCamera         = "SkyCamera"
        case screen            = "Screen"
        case generator         = "Generator"
        case antena            = "Antena"
        case radioDish         = "RadioDish"
        case satellitePlatform = "SatellitePlatform"
        case solarPanel        = "SolarPanel"
        case battery           = "Battery"
        case rover             = "Rover"
        case lander            = "Lander"
        case balloon           = "Balloon"
        case spaceStation      = "SpaceStation"
    }

    public enum ModeOfOperation: String, Codable {
        case manual
        case manualWithAutomatedDetector
        case manualWithAutomatedDetectorAndScheduling
        case autonomous
        case remote
        case mixed                                       // e.g. in case of Network
        case other
        case unknown
    }

}
//MARK: - POLIS mode of operation


//MARK: - Type extensions -

public extension PolisDevice.ModeOfOperation {
    enum CodingKeys: String, CodingKey {
        case manual
        case manualWithAutomatedDetector              = "manual_with_automated_detector"
        case manualWithAutomatedDetectorAndScheduling = "manual_with_automated_detector_and_scheduling"
        case autonomous
        case mixed
        case other
        case unknown
    }
}

