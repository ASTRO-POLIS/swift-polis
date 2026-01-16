//
//  PolisObjectRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

public struct AppSupportStatusChangeNotification {
    // Object Store Notifications
    public static let ObjectChangeNotification = Notification.Name("ObjectChange")
}

enum PolisObjectType {
    case facility
    case facilityDetail
}

enum ChangeInitiationSource {
    case user
    case backend
}

enum ChangeType {
    case newObject
    case updateObject
    case deleteObject
}

struct ObjectChange {
    let changeType: ChangeType
    let changeSource: ChangeInitiationSource
    let object: PersistentObject
}

struct PolisObjectRep<PolisObject> {
    let polisObject: PolisObject
    let localPath: String
    let objectType: PolisObjectType
}

open class PersistentObject: @unchecked Sendable {

    var polisRep: PolisObjectRep<PolisObject>

    init(polisRep: PolisObjectRep<PolisObject>) {
        self.polisRep = PolisObjectRep(polisObject: polisRep as! PolisObject, localPath: "bla", objectType: .facility)
    }
}

public class ObjetChangeDispatcher {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: AppSupportStatusChangeNotification.ObjectChangeNotification, object: nil)
    }

    @MainActor @objc private func handleNotification(notification: NSNotification) {
        Task {
            await ObjectStoreCoordinator.shared.addObservingFacility(notification.object as! ObservingFacility)
        }
    }

}
