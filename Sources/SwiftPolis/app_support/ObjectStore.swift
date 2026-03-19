//
//  ObjectStore.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable public class ObjectStore {

    nonisolated(unsafe) public static let shared = ObjectStore()


    //MARK: - Internal APIs
    func reset() {
        _serviceProvider = nil

        _observingFacilities.removeAll()
    }

    //MARK: - Private APIs
    private var _serviceProvider: ServiceProvider?

    private var _observingFacilities = [ObservingFacility]()
}

//MARK: - Service Provider -
extension ObjectStore {
    public func serviceProvider() -> ServiceProvider? { _serviceProvider }
    func setServiceProvider(_ serviceProvider: ServiceProvider?) { self._serviceProvider = serviceProvider }
}

//MARK: - Observing Facilities -
extension ObjectStore {
}
