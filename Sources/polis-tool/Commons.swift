//
//  Commons.swift
//  swift-polis
//
//  Created by Georg Tuparev on 15.01.26.
//

enum ExitCodes: Int32 {
    case noError                      = 0   // No error
    case invalidArgumentFormat        = 1   // Invalid arguments: arguments outside the allowed set
    case unknown                      = 99  // Unknown error
}
