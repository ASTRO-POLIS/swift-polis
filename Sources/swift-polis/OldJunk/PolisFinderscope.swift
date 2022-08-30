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

// I see no need of finderscope at all. A finedscope is a telescope, and the main instrument can have a list of 0, 1. or more finderscopes
//TODO: Discuss!!!

//public struct PolisFinderscope: Codable {
//    public var item: PolisItem   // Finderscope Identity
//    public var type: [String]
    //Finderscope should inherit the location from the main instrument!
//    public var eastLongitude: Double
//    public var latitude: Double
//    public var elevation: Double
//    public var modeOfOperation: PolisModeOfOperation
//    public var primaryMirrorDiameter: Double
//    public var secondaryMirrorDiameter: Double
//    public var focus: [String]
//    public var focalLength: [Float]
//    public var focalRatio: [String]
//    public var collectingArea: Double
//    public var aperture: Double
//}


//MARK: - Type extensions -


//public extension PolisFinderscope {
//    enum CodingKeys: String, CodingKey {
//
//        public var type: [String]
//        public var eastLongitude: Double
//        public var latitude: Double
//        public var elevation: Double
//        public var modeOfOperation: PolisModeOfOperation
//        public var primaryMirrorDiameter: Double
//        public var secondaryMirrorDiameter: Double
//        public var focus: [String]
//        public var focalLength: [Float]
//        public var focalRatio: [String]
//        public var collectingArea: Double
//        public var aperture: Double
//
//        case item
//        case modeOfOperation = "mode_of_operation"
//    }
//}
