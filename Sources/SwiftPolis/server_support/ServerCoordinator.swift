//
//  ServerCoordinator.swift
//  swift-polis
//
//  Created by Georg Tuparev on 28.04.26.
//

import Foundation

// Big assumption: the POLIS provider (static local data) already exists, it is empty (only required files are present),
// and all dates are set way in the past (e.g. 01.01.2000 00:00h).q

public final class ServerCoordinator {
    // Similar to the ObjectStoreCoordinator we need to set stuff like root path, is it test mode

}


//MARK: - Service Providing -
extension ServerCoordinator {

    public func polisServiceProvider() async throws -> PolisDirectory.ProviderDirectoryEntry {
        //TODO: Implement me!
        fatalError("ServerCoordinator : polisServiceProvider not implemented!")
    }

    public func polisServiceProviderDirectory() async throws -> PolisDirectory {
        fatalError("ServerCoordinator : polisServiceProviderDirectory not implemented!")
    }

}
