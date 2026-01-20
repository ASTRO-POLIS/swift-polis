//
//  PolisLogger.swift
//  swift-polis
//
//  Created by Ani Klekchyan on 22.11.25.

import Foundation
import Logging
import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching

public enum PolisLogger {
    
    /// Setup logging - call once at app start
    /// - Parameters:
    ///   - subsystem: The subsystem identifier for OSLog (e.g., "com.polis.app")
    ///   - level: The minimum log level to capture
    ///   - logFileURL: Optional URL to a log file. If provided, logs will also be written to this file.
    ///   - includeConsole: If true, logs will also be printed to stdout (terminal). Default is false.
    public static func setup(subsystem: String = "com.polis.package", level: Logging.Logger.Level = .info, logFileURL: URL? = nil,includeConsole: Bool = false) {
        
        var dispatchers: [MessageDispatching] = [OSLogDispatcher(subsystem: subsystem, category: "Package")]
        
        if includeConsole {
            dispatchers.append(ConsoleDispatcher())
        }
        
        if let fileURL = logFileURL {
            if let fileDispatcher = try? FileDispatcher(fileURL: fileURL) {
                dispatchers.append(fileDispatcher)
            }
        }
        
        let handler = SoftwareEtudesLogging.Logger(logLevel: level, dispatchers: dispatchers)
        LoggingSystem.bootstrap { _ in handler }
    }
    
    /// Get a logger
    public static func logger(_ name: String = "default") -> Logging.Logger {
        Logging.Logger(label: name)
    }
}
