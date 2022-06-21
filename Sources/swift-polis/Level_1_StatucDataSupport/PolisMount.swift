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

public enum PolisMountModeOfOperation: String, Codable {
    case manual
    case remote
    case robotic
    case unknown
}

public class PolisMount: Codable {
    public var item: PolisItem   // Mount Identification
    public var type: [String]
    public var modeOfOperation: PolisMountModeOfOperation
    
}


//MARK: - Type extensions -


public extension PolisMount {
    enum CodingKeys: String, CodingKey {
        case item
        case modeOfOperation = "mode_of_operation"
    }
}
