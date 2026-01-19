//
//  PolisLogger.swift
//  swift-polis
//
//  Created by Ani Klekchyan on 22.11.25.

import Foundation
import Logging
import SoftwareEtudesLogging

public enum PolisLogger {
    
    /// Setup logging - call once at app start
    public static func setup(subsystem: String = "com.polis.app", level: Logging.Logger.Level = .info) {
        let dispatcher = OSLogDispatcher(subsystem: subsystem, category: "App")
        let handler    = SoftwareEtudesLogging.Logger(logLevel: level, dispatchers: [dispatcher])
        LoggingSystem.bootstrap { _ in handler }
    }
    
    /// Get a logger
    public static func logger(_ name: String = "default") -> Logging.Logger {
        Logging.Logger(label: name)
    }
}
