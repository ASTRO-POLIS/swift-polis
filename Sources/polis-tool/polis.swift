//
//  polis.swift
//  swift-polis
//
//  Created by Georg Tuparev on 29.11.25.
//

import Foundation
import SoftwareEtudesUtilities
@preconcurrency import SoftwareEtudesExecutableConfiguration
import SoftwareEtudesLogging
import swift_polis


    let helpPrompt = """
NAME
   polis

SYNOPSIS
   polis -c path_to_local_polis_root  -r url_to_remote_polis_provider [-t | --test] [-m | --mode] [status | create sync]
   polis -h | --help

DESCRIPTION
   Validates the content of the input directory and prepares configuration files and templates for all other eMandate tools

ARGUMENTS
   -c path_to_local_polis_folder         -- The path to the local copy of the POLIS provider static data [optional in test mode]
   -r url_to_remote_polis_provider       -- The fURL to the remote POLIS provider used for syncing [required]
   --mode status | create | sync         -- Defines one of the three execution modi [optional]
                                         -- - status: returns the status of the local and the remote service provider 
                                         -- - create: creates a new local service provider
                                         -- - sync: bidirectional sync between the local and the remote service providers
   --log                                 -- Path to the log file. If absent, the tool prints only to the console. [optional]
   --log_level [DEBUG | WARNING | ERROR] -- Defines the logging level. Default is WARNING [optional]
   -t | --test                           -- Executes the utility in test mode. Can use build-in configuration. Could be used ONLY 
                                            while debugging. Changes are temporary only! [optional]
   -h | --help                           -- Prints this help

EXIT STATUS
   The polis utility exits 0 on success, and > 0 if an error occurs
    1   -- Invalid arguments: arguments outside the allowed set
   99   -- unknown error
"""

@MainActor var storeCoordinator: ObjectStoreCoordinator!
@MainActor var exitCode  = ExitCodes.noError
@MainActor var isTesting = false
@MainActor var modeOfOperation: ModeOfOperation!
@MainActor var logLevel  = LogLevel.debug

@MainActor var rootPath: String?
@MainActor var remoteHost: String?
@MainActor var logFile: String?
let testingPath          = "/Users/Shared/Work/polis_tests"

@main
struct PolisTool {

    static func main() async throws {
        //MARK: Implement me!

        // 1. Parse the command line arguments
        parseArguments()

        // 2. Check arguments
        if !areArgumentsValid() { exitDescribingErrors(code: exitCode) }

        //TODO: 3. Check paths

        //TODO: N Configure ObjectStoreCoordinator
        storeCoordinator = ObjectStoreCoordinator.shared

        //TODO: N. Setup various controllers
        //TODO: N. Decide what to do
    }

}

//MARK: - Private API -
fileprivate let clap                       = CommandLineParser(arguments: CommandLine.arguments)
@MainActor fileprivate var fm              = FileManager.default
@MainActor fileprivate var isDir: ObjCBool = false


@MainActor private func parseArguments() {
    guard let clap = clap else { fatalError("FATAL ERROR: cannot initialise command line parser ") }

    do    { try clap.setAllowedArguments(["-l", "--log", "-h", "--help", "-t", "--test", "-c", "-r", "--mode", "--log_level"]) }
    catch { exitDescribingErrors(code: .invalidArgumentFormat) }

    if clap.containsRaw(argument: "-h") || clap.containsRaw(argument: "--help") {
        print(helpPrompt)
        exitDescribingErrors(code: .noError)
    }

    if clap.containsRaw(argument: "-c")                                         { rootPath        = clap.firstRawArgument(after: "-c") }
    if clap.containsRaw(argument: "-r")                                         { remoteHost      = clap.firstRawArgument(after: "-r") }
    if clap.containsRaw(argument: "--mode")                                     { modeOfOperation = ModeOfOperation(rawValue: clap.firstRawArgument(after: "--mode")!) }
    if clap.containsRaw(argument: "-log")                                       { logFile         = clap.firstRawArgument(after: "-log") }
    if clap.containsRaw(argument: "--log_level")                                { logLevel        = LogLevel(rawValue: clap.firstRawArgument(after: "--log_level")!) ?? .warning }
    if clap.containsRaw(argument: "-t") || clap.containsRaw(argument: "--test") { isTesting       = true }
}

@MainActor private func areArgumentsValid() -> Bool {
    if !isTesting && (rootPath == nil) {
        exitCode = .pathToLocalProviderIsRequired
        return false
    }

    if (modeOfOperation == .sync) && (remoteHost == nil) {
        exitCode = .remoteHostProviderIsRequired
        return false
    }

    //TODO: Implement me!
    return true
}

@MainActor private func exitDescribingErrors(code: ExitCodes) {
    if code != ExitCodes.noError {
        print(helpPrompt)

        switch code {
            case .noError: break
            case .invalidArgumentFormat:         print(">>> Invalid arguments: arguments outside the allowed set")
            case .pathToLocalProviderIsRequired: print(">>> If the tool is not in test mode, the \"-c path\" argument is required")
            case .remoteHostProviderIsRequired:  print(">>> In sync mode mode, the \"-r url\" argument is required")
            case .unknown:                       print(">>> Unknown error")
        }
        print(">>> Exiting with errors)")
    }
    exit(code.rawValue)
}

