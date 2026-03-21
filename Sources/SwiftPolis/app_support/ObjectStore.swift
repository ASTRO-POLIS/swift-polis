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

    }
    //MARK: - Internal APIs
    func reset() {
        _serviceProvider.withLock { $0 = nil }
        _observingFacilities.withLock { $0.removeAll() }
    }

    //MARK: - Private APIs
    private let _serviceProvider     = Mutex<ServiceProvider?>(nil)
    private let _observingFacilities = Mutex<[ObservingFacility]>([])
}

//MARK: - Service Provider -
extension ObjectStore {
    public func serviceProvider() -> ServiceProvider? {
        _serviceProvider.withLock { return $0 }
    }

    func setServiceProvider(_ serviceProvider: ServiceProvider?) {
        _serviceProvider.withLock { $0 = serviceProvider }
    }
}

//MARK: - Observing Facilities -
extension ObjectStore {
    public func observingFacilities() -> [ObservingFacility] {
        _observingFacilities.withLock{ return $0 }
    }

    public func add(observingFacility: ObservingFacility) {
        _observingFacilities.withLock{ $0.append(observingFacility) }
    }
}

