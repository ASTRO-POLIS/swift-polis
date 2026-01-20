//
//  Commons.swift
//  swift-polis
//
//  Created by Georg Tuparev on 15.01.26.
//

enum LogLevel: String {
    case debug   = "DEBUG"
    case warning = "WARNING"
    case error   = "ERROR"
}

enum ModeOfOperation: String {
    case status
    case create
    case sync
}

enum ExitCodes: Int32 {
    case noError                       = 0   // No error
    case invalidArgumentFormat         = 1   // Invalid arguments: arguments outside the allowed set
    case pathToLocalProviderIsRequired = 2   // If the tool is not in test mode, the "-c path" argument is required
    case remoteHostProviderIsRequired  = 3   // In sync mode mode, the "-r url" argument is required
    case unknown                       = 99  // Unknown error
}
