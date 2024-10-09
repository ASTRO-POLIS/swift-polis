//
//  PolisLogger.swift
//  swift-polis
//
//  Created by Georg Tuparev on 9.10.24.
//

import Foundation

/// A very simple Logger that tracks the entire `info`, `warning`, and `error` message stack
///
/// This very primitive Logger implementation could be useful mostly for debugging purposes.. Consider using proper Logger in more
///  complex applications.
public class PolisLogger {

    public static var shared = PolisLogger()

    /// Should logging messages be accumulated.
    public var shouldLog = true

    public func infoMessages()    -> [String] { [String]() }
    public func warningMessages() -> [String] { [String]() }
    public func errorMessages()   -> [String] { [String]() }

    /// Delete all messages until now
    public func flush() {
        _infoMessages.removeAll()
        _warningMessages.removeAll()
        _errorMessages.removeAll()
    }

    //MARK: Internal
    func info(_ message: String)    { if shouldLog { _infoMessages.append(message) } }
    func warning(_ message: String) { if shouldLog { _warningMessages.append(message) } }
    func error(_ message: String)   { if shouldLog { _errorMessages.append(message) } }

    //Mark: Private stuff
    private var _infoMessages    = [String]()
    private var _warningMessages = [String]()
    private var _errorMessages   = [String]()
}
