//
//  polis.swift
//  swift-polis
//
//  Created by Georg Tuparev on 29.11.25.
//

import Foundation
import SoftwareEtudesUtilities
@preconcurrency import SoftwareEtudesExecutableConfiguration

    let helpPrompt = """
NAME
   polis

SYNOPSIS
   polis -l path_to_local_polis_root  -r url_to_remote_polis_provider [-t | --test] [-m | --mode] [status | create sync]
   polis -h | --help

DESCRIPTION
   Validates the content of the input directory and prepares configuration files and templates for all other eMandate tools

ARGUMENTS
   -c path_to_local_polis_folder         -- The path to the local copy of the POLIS provider static data [required]
   -r url_to_remote_polis_provider       -- The fURL to the remote POLIS provider used for syncing [required]
   -m | --mode status | create | sync    -- Defines one of the three execution modi [optional]
                                         -- - status: returns the status of the local and the remote service provider 
                                         -- - create: creates a new local service provider
                                         -- - sync: bidirectional sync between the local and the remote service providers
   -l | --log                            -- Path to the log file. If absent, the tool prints only to the console. [optional]
   --log_level [DEBUG | WARNING | ERROR] -- Defines the logging level. Default is WARNING [optional]
   -t | --test                           -- Executes the utility in test mode. Can use build-in configuration. Could be used ONLY 
                                            while debugging. Changes are temporary only! [optional]
   -h | --help                           -- Prints this help

EXIT STATUS
   The polis utility exits 0 on success, and > 0 if an error occurs
   99   -- unknown error
"""

@MainActor var exitCode = ExitCodes.noError

@main
struct PolisTool {

    static func main() async throws {
        //MARK: Implement me!

        // 1. Parse the command line arguments
        parseArguments()

        //TODO: 2. Check arguments and paths
        //TODO: N. Setup various controllers
        //TODO: N. Decide what to do

        print(helpPrompt)
    }

}

//MARK: - Private API -
fileprivate let clap = CommandLineParser(arguments: CommandLine.arguments)

@MainActor private func parseArguments() {
    guard let clap = clap else { fatalError("FATAL ERROR: cannot initialise command line parser ") }

    do    { try clap.setAllowedArguments(["-l"]) }
    catch { exitDescribingErrors(code: exitCode.rawValue) }
    //MARK: Implement me!
}

@MainActor private func exitDescribingErrors(code: Int32) {
    //TODO: Describe the error!
    if code != ExitCodes.noError.rawValue {
        print("Exiting with errors)")
        print(helpPrompt)
    }
    exit(exitCode.rawValue)
}
