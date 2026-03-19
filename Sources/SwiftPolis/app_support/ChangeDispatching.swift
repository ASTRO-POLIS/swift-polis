//
//  ChangeDispatching.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

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

public class ObjetChangeDispatcher {
    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: PolisChangeNotification.ObjectChangeNotification, object: nil)
    }

    @MainActor @objc private func handleNotification(notification: NSNotification) {
    }

}
