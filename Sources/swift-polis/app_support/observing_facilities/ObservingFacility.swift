//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable open class ObservingFacility: PersistentObject, @unchecked Sendable {

    public static func newObservingFacility() -> ObservingFacility {
        let identity          = PolisIdentity()
        let facilityReference = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
        let rep               = PolisObjectRep(polisObject: facilityReference, localPath: "", objectType: PolisObjectType.facility)
        let facility          = ObservingFacility(polisRep: rep as! PolisObjectRep)
        let change            = ObjectChange(changeType: .newObject, changeSource: .user, object: facility)

//        NotificationCenter.default.post(name: PolisChangeNotification.ObjectChangeNotification, object: change)

        //TODO: Implement me!
        return facility
    }

    func update() { }
}

