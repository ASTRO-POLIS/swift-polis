//===----------------------------------------------------------------------===//
//  PolisLogger.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//
//
//  Created by Georg Tuparev on 09.10.2024
//

import Foundation

/// A very simple Logger that tracks the entire `info`, `warning`, and `error` message stack
///
/// This very primitive Logger implementation could be useful mostly for debugging purposes.. Consider using proper Logger in more
///  complex applications.
///
///  **Note:** Future versions of `swift-polis` will use `SoftwareEtudes`' logging library.
public class PolisLogger {

    @MainActor public static let shared = PolisLogger()

    /// Should logging messages be accumulated.
    public var shouldLog = true

    /// Info logs that inform what is happening
    public func infoMessages()    -> [String] { _infoMessages }

    ///  Non-critical warnings
    ///
    ///  Most probable cause are unsuccessful remote data syncing operations. The framework could be used further.
    public func warningMessages() -> [String] { _warningMessages }

    /// Critical errors that will most probably terminate the normal work of the framework and need special attention.
    public func errorMessages()   -> [String] { _errorMessages }

    /// Delete all messages until now
    public func flush() {
        _infoMessages.removeAll()
        _warningMessages.removeAll()
        _errorMessages.removeAll()
    }

    //MARK: Internal

    // All methods are adding a timestamp
    func info(_ message: String)    { if shouldLog { _infoMessages.append( PolisLogger.logFormatter(message)) } }
    func warning(_ message: String) { if shouldLog { _warningMessages.append(PolisLogger.logFormatter(message)) } }
    func error(_ message: String)   { if shouldLog { _errorMessages.append(PolisLogger.logFormatter(message)) } }

    //Mark: Private stuff
    private var _infoMessages    = [String]()
    private var _warningMessages = [String]()
    private var _errorMessages   = [String]()

    // We need this to guarantee a consistent format.
    private static func logFormatter(_ message: String) -> String { "\(Date.now) -- \(message)" }
}
