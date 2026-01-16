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
        _observingFacilities.removeAll()
    }

    //MARK: - Private APIs
    public internal(set) var observingFacilities = [ObservingFacility]()
}

//MARK: - Observing Facilities -
extension ObjectStore {

    func addObservingFacility(_ facility: ObservingFacility) { _observingFacilities.append(facility) }

}
