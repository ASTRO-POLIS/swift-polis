//
//  ObjectStore.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation
import Synchronization

@Observable public final class ObjectStore: Sendable {

   public static let shared = ObjectStore()

    init() {
        //TODO: Implement me!
    }

    //MARK: - Internal APIs
    func reset() {
        _serviceProvider.withLock { $0 = nil }
        _observingFacilities.withLock { $0.removeAll() }
    }

    //MARK: - Private APIs
    private let _serviceProvider            = Mutex<ServiceProvider?>(nil)
    private let _serviceProvidersDirectory  = Mutex<ServiceProviderDirectory?>(nil)
    private let _observingFacilityDirectory = Mutex<ObservingFacilityDirectory?>(nil)
    private let _observingFacilities        = Mutex<[ObservingFacility]>([])
}

//MARK: - Service Provider -
extension ObjectStore {
    public func serviceProvider() -> ServiceProvider? { _serviceProvider.withLock { return $0 } }
    func setServiceProvider(_ serviceProvider: ServiceProvider?) { _serviceProvider.withLock { $0 = serviceProvider } }

    public func serviceProviderDirectory() -> ServiceProviderDirectory? { _serviceProvidersDirectory.withLock { return $0 } }
    func setServiceProvider(_ serviceProviderDirectory: ServiceProviderDirectory?) { _serviceProvidersDirectory.withLock { $0 = serviceProviderDirectory } }

    public func observingFacilityDirectory() -> ObservingFacilityDirectory? { _observingFacilityDirectory.withLock { return $0 } }
    func setObservingFacilities(_ observingFacilityDirectory: ObservingFacilityDirectory?) { _observingFacilityDirectory.withLock { $0 = observingFacilityDirectory } }
}

//MARK: - Observing Facilities -
extension ObjectStore {
    public func observingFacilities() -> [ObservingFacility] { _observingFacilities.withLock{ return $0 } }
    public func add(observingFacility: ObservingFacility) { _observingFacilities.withLock{ $0.append(observingFacility) } }
}

