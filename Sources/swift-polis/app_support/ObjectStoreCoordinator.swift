//
//  ObjectStoreCoordinator.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

public actor ObjectStoreCoordinator {
    @MainActor public static let shared = ObjectStoreCoordinator()

}

//MARK: - Managing Observing Facilities -
extension ObjectStoreCoordinator {

    public func addObservingFacility(_ facility: ObservingFacility) { ObjectStore.shared.addObservingFacility(facility) }
}
