//
//  PolisLocalDataLoader.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23.05.25.
//

import Foundation

actor PolisLocalDataLoader {

    //MARK: Non-private APIs
    static var shared = PolisLocalDataLoader()

    func scheduleForLoading(_ item: any PolisPersisting, withPriority: Bool = false) async {
        if withPriority { localPolisDataToLoad.insert(item, at: 0) }
        else            { localPolisDataToLoad.append(item) }
    }

    func startLoading() async throws {
        for item in localPolisDataToLoad {
            postWillLoadNotification(item: item)
            try item.loadData()
            postDidLoadNotification(item: item)
        }
        localPolisDataToLoad.removeFirst()
    }

    //MARK: Private APIs
    private let nc = NotificationCenter.default
    private var localPolisDataToLoad = [any PolisPersisting]()

    private func postWillLoadNotification(item: any PolisPersisting) {
        if      let item = item as? ObservingFacilityRep { nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillLoadNotification, object: item) }
        else if let item = item as? EarthFixBasedObservingFacilityRep { }
        else if let item = item as? ObservatoryRep { }
        else if let item = item as? DeviceRep { }
        else if let item = item as? MediaSourceRep { }
        else if let item = item as? ArtifactRep { }
        //TODO: Implement me!
   }

    private func postDidLoadNotification(item: any PolisPersisting) {
        if      let item = item as? ObservingFacilityRep { nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidLoadNotification, object: item) }
        else if let item = item as? EarthFixBasedObservingFacilityRep { }
        else if let item = item as? ObservatoryRep { }
        else if let item = item as? DeviceRep { }
        else if let item = item as? MediaSourceRep { }
        else if let item = item as? ArtifactRep { }
        //TODO: Implement me!
    }
}
