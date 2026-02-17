//
//  ServiceProvider.swift
//  swift-polis
//
//  Created by Georg Tuparev on 17.02.26.
//

import Foundation

open class ServiceProvider {

    public private(set) var id: UUID!
    public var mirrorID: UUID?
    public var reachabilityStatus = PolisDirectory.ProviderDirectoryEntry.ServiceReachability.localUseOnly
    public var name = "<unnamed>"
    public var shortDescription: String?
    public var lastUpdateTime = Date.now
    public var url: String?
    public var supportedImplementations: [PolisImplementation] = []
    public var providerType = PolisDirectory.ProviderDirectoryEntry.ProviderType.experimental
    //TODO: Implement me!    public var contact: Person

    //MARK: Private APIs
    private var _originalPolisRecord: PolisDirectory.ProviderDirectoryEntry?
}
