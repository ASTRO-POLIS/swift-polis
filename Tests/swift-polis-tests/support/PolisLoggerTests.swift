//===----------------------------------------------------------------------===//
//  PolisLoggerTests.swift
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
//  Created by Georg Tuparev on 20/10/2024
//

import Testing
import Foundation
import Logging
import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching

@testable import SwiftPolis

//MARK: - Console Tests Suite

@Suite("PolisLogger Console Tests")
@MainActor
struct PolisLoggerConsoleTests {
    
    //MARK: - Setup
    
    /// Use ObjectStoreCoordinator to initialise the logger
    static func setupLogger() {
        _ = ObjectStoreCoordinator.shared
    }
    
    //MARK: - Tests: Logger Creation
    
    @Test("Logger with default name should have 'default' label")
    func loggerWithDefaultName() {
        Self.setupLogger()
        let logger = PolisLogger.logger()
        #expect(logger.label == "default")
    }
    
    @Test("Logger with custom name should have that name as label")
    func loggerWithCustomName() {
        Self.setupLogger()
        let logger = PolisLogger.logger("CustomLogger")
        #expect(logger.label == "CustomLogger")
    }
    
    //MARK: - Tests: Console Output
    
    @Test("Info log should appear in console")
    func infoLogToConsole() {
        Self.setupLogger()
        let logger = PolisLogger.logger("InfoTest")
        logger.info("=== INFO: This message should appear in Xcode console ===")
    }
    
    @Test("Warning log should appear in console")
    func warningLogToConsole() {
        Self.setupLogger()
        let logger = PolisLogger.logger("WarningTest")
        logger.warning("=== WARNING: This message should appear in Xcode console ===")
    }
    
    @Test("Error log should appear in console")
    func errorLogToConsole() {
        Self.setupLogger()
        let logger = PolisLogger.logger("ErrorTest")
        logger.error("=== ERROR: This message should appear in Xcode console ===")
    }
    
    @Test("Debug log should appear in console")
    func debugLogToConsole() {
        Self.setupLogger()
        let logger = PolisLogger.logger("DebugTest")
        logger.debug("=== DEBUG: This message should appear in Xcode console ===")
    }
    
    @Test("Critical log should appear in console")
    func criticalLogToConsole() {
        Self.setupLogger()
        let logger = PolisLogger.logger("CriticalTest")
        logger.critical("=== CRITICAL: This message should appear in Xcode console ===")
    }
}

//MARK: - File Dispatcher Tests Suite

@Suite("PolisLogger File Dispatcher Tests")
@MainActor
struct PolisLoggerFileTests {
    
    //MARK: - Properties
    static let testLogFileURL = URL(fileURLWithPath: "/tmp/polis.log")
    
    //MARK: - Setup
    
    /// Setup logger via ObjectStoreCoordinator (same as console tests)
    static func setupFileLogger() {
        _ = ObjectStoreCoordinator.shared
    }
    
    //MARK: - Helper Methods
    
    /// Waits for file dispatcher to flush and returns file content
    private func waitAndReadLogFile() async throws -> String {
        // Wait longer for async Task.detached in SoftwareEtudesLogging.Logger
        try await Task.sleep(for: .seconds(5))
        
        print("🔍 Checking file at: \(Self.testLogFileURL.path)")
        
        let fileExists = FileManager.default.fileExists(atPath: Self.testLogFileURL.path)
        print("🔍 File exists: \(fileExists)")
        
        guard fileExists else {
            throw FileTestError.logFileNotFound
        }
        
        let content    = try String(contentsOf: Self.testLogFileURL, encoding: .utf8)
        return content
    }
    
    enum FileTestError: Error {
        case logFileNotFound
    }
    
    //MARK: - Tests: File Creation
    
    @Test("Log file should be created after logging")
    func logFileCreated() async throws {
        Self.setupFileLogger()
        
        let logger     = PolisLogger.logger("FileCreationTest")
        logger.info("Trigger file creation")
        
        try await Task.sleep(for: .seconds(3))
        
        let fileExists = FileManager.default.fileExists(atPath: Self.testLogFileURL.path)
        #expect(fileExists, "Log file should exist at \(Self.testLogFileURL.path)")
    }
}
