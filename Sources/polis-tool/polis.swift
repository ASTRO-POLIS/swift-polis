//
//  polis.swift
//  swift-polis
//
//  Created by Georg Tuparev on 29.11.25.
//

import Foundation
import Logging
import SoftwareEtudesUtilities
@preconcurrency import SoftwareEtudesExecutableConfiguration
import SoftwareEtudesLogging
import SwiftPolis


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
   --mode status | create | sync | list
                                         -- Defines one of the three execution modi [optional]
                                         -- - status: returns the status of the local and the remote service provider (default)
                                         -- - create: creates a new local service provider
                                         -- - sync: bidirectional sync between the local and the remote service providers
                                         -- - list: list all observing facilities
   --log                                 -- Path to the log file. If absent, the tool prints only to the console. [optional]
   --log_level [DEBUG | WARNING | ERROR] -- Defines the logging level. Default is WARNING [optional]
   -t | --test                           -- Executes the utility in test mode. Can use build-in configuration. Could be used ONLY 
                                            while debugging. Changes are temporary only! [optional]
   -h | --help                           -- Prints this help

EXIT STATUS
   The polis utility exits 0 on success, and > 0 if an error occurs
    1   -- Invalid arguments: arguments outside the allowed set
    2   -- If the tool is not in test mode, the "-c path" argument is required
    3   -- In sync mode mode, the "-r url" argument is required
    4   -- File I/O Error
    5   -- Cannot configure the Object Store Configurator
    6   -- Cannot create local POLIS Service Provider
   99   -- Unknown error
"""

@MainActor var storeCoordinator: ObjectStoreCoordinator!
@MainActor var exitCode        = ExitCodes.noError
@MainActor var isTesting       = false
@MainActor var modeOfOperation = ModeOfOperation.status
@MainActor var logLevel        = LogLevel.debug

@MainActor var rootPath: String?
@MainActor var remoteHost: String?
@MainActor var logger: Logging.Logger!
@MainActor var logFile: String?
let testingPath                = "/Users/Shared/Work/polis_tests"

final class PolisTerminationHandler: CommandLineParserDelegate {
    func processWillTerminate() -> Bool {
        PolisLogger.flush()
        return true
    }
}

@main
struct PolisTool {

    static func main() async throws {
        //MARK: Implement me!

        // 1. Parse the command line arguments
        await parseArguments()

        // 2. Check arguments
        if !areArgumentsValid() { await exitDescribingErrors(code: exitCode) }

        // 3. Check paths
        if !makeSureRootPathExists() {
            exitCode = .fileIO
            await exitDescribingErrors(code: exitCode)
        }

        //TODO: N Configure ObjectStoreCoordinator
        ObjectStoreCoordinator.isBigBangServiceProvider = true // Should be `true` in case this is the initial (primordial) Service Provider
        storeCoordinator = ObjectStoreCoordinator.shared

        // N. Configure the logger
        try await storeCoordinator.setLogFilePath("/tmp/astro/polis.log") // This should be set only on macOS! Default value is /tmp/polis.log
        logger = await storeCoordinator.logger()
        logger.info("Polis tool started")

        do    { try await storeCoordinator.setPathToPolisFolder(rootPath!) }
        catch {
            exitCode = .cannotConfigureStoreConfigurator
            await exitDescribingErrors(code: exitCode)
        }
        logger.info("Polis tool configuration complete")

        //TODO: N. Setup various controllers

        //TODO: N. Decide what to do
        switch modeOfOperation {
            case .status: try await requestLocalProviderStatus()
            case .create: try await createNewLocalObjectStore() 
            case .sync:   logger.info("Object Store sync not implemented")
            case .list:   try await listFacilities()
        }
        
        // Prepare the app to terminate
        await exitDescribingErrors(code: exitCode)
    }

    @MainActor static func requestLocalProviderStatus() async throws {
        let objectStoreDescription = try await storeCoordinator.objectStoreStatus()
        let objectStoreStatus      = objectStoreDescription.status

        print("LOCAL POLIS SERVICE PROVIDER STATUS")

        switch objectStoreStatus {
            case .notConfigured:                        print("    Status: Not Configured - the root path is not set" )
            case .rootPathSetAndValid:                  print("    Status: Root Path Set And Valid - the root folder exists and is accessible, but sub-folders are missing" )
            case .folderHierarchyCreated:               print("    Status: Folder Hierarchy Created - there are missing basic configuration files" )
            case .fullyConfigured: break
            case .fullyConfiguredAndSynced: break
            case .misconfiguredOrMissingEssentialFiles: break
        }
        //TODO: Implement me!

        // Now describe the status
        print("---> Root path status: \(objectStoreDescription.rootPathAccessibilityStatus.rawValue)")
        print("---> Root path: \(objectStoreDescription.rootPath ?? "<not set>")")
        print("---> Essential POLIS Service Provider configuration folders status: \(objectStoreDescription.polisFoldersAccessibilityStatus.rawValue)")
        print("---> Essential POLIS Service Provider configuration files status: \(objectStoreDescription.polisFilesAccessibilityStatus.rawValue)")
        print("---> POLIS Service Provider File Resource Finder Status: \(objectStoreDescription.polisFileResourceFinderStatus.rawValue)")
    }

    //TODO: By default this will create BigBang provider, and this is not good. We should ask (and make it a default) behaviour to use the BigBang as a remote server (set automatically)!
    @MainActor static func createNewLocalObjectStore() async throws {
        let objectStoreDescription = try await storeCoordinator.objectStoreStatus()
        let objectStoreStatus      = objectStoreDescription.status

        print("LOCAL POLIS SERVICE PROVIDER CREATION")

        if objectStoreStatus.rawValue >= ObjectStoreStatusType.fullyConfigured.rawValue {
            logger.info( "A local object store has already been configured. Aborting.")
            await exitDescribingErrors(code: .noError)
        }
        else {
            do {
                try await storeCoordinator.createLocalStore()
                logger.info( "A local object store has been successfully created and configured.")

                // Create some facility examples
                if isTesting { try await createTestEnvironment() }

                await exitDescribingErrors(code: .noError)
            }
            catch {
                logger.error( "Failed to create a local object store. Aborting.")
                await exitDescribingErrors(code: .cannotCreateLocalProvider)
            }
        }

    }

    @MainActor static func createTestEnvironment() async throws {
        let newFacility = try await storeCoordinator.createObservingFacility(id: UUID(),
                                                                             observingFacilityCode: "1234",
                                                                             placeInTheSolarSystem: .earth,
                                                                             gravitationalBodyRelationship: .surfaceFixed)
        let newDetails  = try await newFacility.observingFacilityDetails(createIfDoesNotExist: true)

        newDetails!.website = URL(string:"https://example.com")

        //TODO: Post AppWillTerminate!
        //TODO: Implement me!
    }

    @MainActor static func listFacilities() async throws {
        print("LOCAL POLIS SERVICE PROVIDER - LIST FACILITIES")

        let objectStoreDescription = try await storeCoordinator.objectStoreStatus()
        let objectStoreStatus      = objectStoreDescription.status

        if objectStoreStatus.rawValue >= ObjectStoreStatusType.fullyConfigured.rawValue {
            print("---> Local Service Provider is ready to be loaded ...")
            do {
                try await storeCoordinator.loadLocalStore()

                let os = ObjectStore.shared
                print("   ---> Latest change time: \(os.serviceProvider()?.lastUpdateTime, default: "not available")")
                print("   ---> Number of facilities: \(os.observingFacilities().count, default: "0")")
                //TODO: To be continued!
           }
            catch {
                print("---> ERROR: Local Service Provider failed to load. Aborting.")
            }
        }
        else { print("---> ERROR: Local Service Provider is not yet ready to be loaded (status: \(objectStoreStatus.rawValue).") }
    }
}

//MARK: - Private API -
fileprivate let _clap                       = CommandLineParser(arguments: CommandLine.arguments)
@MainActor fileprivate var _fm              = FileManager.default
@MainActor fileprivate var _isDir: ObjCBool = false


@MainActor private func parseArguments() async {
    guard let _clap = _clap else { fatalError("FATAL ERROR: cannot initialise command line parser ") }

    _clap.commandLineParserDelegate = PolisTerminationHandler()

    do    { try _clap.setAllowedArguments(["-l", "--log", "-h", "--help", "-t", "--test", "-c", "-r", "--mode", "--log_level"]) }
    catch { await exitDescribingErrors(code: .invalidArgumentFormat) }

    if _clap.containsRaw(argument: "-h") || _clap.containsRaw(argument: "--help") {
        print(helpPrompt)
        await exitDescribingErrors(code: .noError)
    }

    if _clap.containsRaw(argument: "-c")                                          { rootPath        = _clap.firstRawArgument(after: "-c") }
    if _clap.containsRaw(argument: "-r")                                          { remoteHost      = _clap.firstRawArgument(after: "-r") }
    if _clap.containsRaw(argument: "--mode")                                      { modeOfOperation = ModeOfOperation(rawValue: _clap.firstRawArgument(after: "--mode")!) ?? .status }
    if _clap.containsRaw(argument: "-log")                                        { logFile         = _clap.firstRawArgument(after: "-log") }
    if _clap.containsRaw(argument: "--log_level")                                 { logLevel        = LogLevel(rawValue: _clap.firstRawArgument(after: "--log_level")!) ?? .warning }
    if _clap.containsRaw(argument: "-t") || _clap.containsRaw(argument: "--test") {
        rootPath  = testingPath
        isTesting = true
    }
}

@MainActor private func areArgumentsValid() -> Bool {
    if rootPath == nil {
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

@MainActor private func makeSureRootPathExists() -> Bool {
    if !(_fm.fileExists(atPath: rootPath!, isDirectory: &_isDir) && (_isDir.boolValue)) {
        do    { try _fm.createDirectory(atPath: rootPath!, withIntermediateDirectories: true) }
        catch { return false }
    }

    return true
}

@MainActor private func exitDescribingErrors(code: ExitCodes) async {
    if code != ExitCodes.noError {
        print(helpPrompt)

        switch code {
            case .noError: break
            case .invalidArgumentFormat:            print(">>> Invalid arguments: arguments outside the allowed set")
            case .pathToLocalProviderIsRequired:    print(">>> If the tool is not in test mode, the \"-c path\" argument is required")
            case .remoteHostProviderIsRequired:     print(">>> In sync mode mode, the \"-r url\" argument is required")
            case .fileIO:                           print(">>> File I/O failed")
            case .cannotConfigureStoreConfigurator: print(">>> Cannot configure the Object Store Configurator. Multiple reasons are possible.")
            case .cannotCreateLocalProvider:        print(">>> Cannot create local POLIS Service Provider" )
            case .unknown:                          print(">>> Unknown error")
        }
        print(">>> Exiting with errors)")
    }
    _clap?.prepareProcessForTermination()

    // Wait for async logging to complete before exit
    try? await Task.sleep(for: .seconds(1))
    exit(code.rawValue)
}

