//
//  AppNotifications.swift
//  swift-polis
//
//  Created by Georg Tuparev on 24.02.26.
//

import Foundation

/// The goal of the new notification mechanism is to unify and simplify change notifications that are posted either by
/// clients (UI or server-side components), or changing persistent data (local or remote). `PolisNotificationPayload`
/// combines all information needed to achieve this goal.
struct PolisNotificationPayload {

    enum ActionType {
        case sync
        case load
        case create
        case update
        case delete
    }

    let entity: PolisObjectType
    let actionType: ActionType
    let id: UUID?
    let polisObject: (any PolisObject)?

    init(entity: PolisObjectType, actionType: ActionType, id: UUID? = nil, polisObject: (any PolisObject)? = nil) {
        self.entity      = entity
        self.actionType  = actionType
        self.id          = id
        self.polisObject = polisObject
    }
}


/// This Notification Message is posted by the `ObjectStoreCoordinator` when any persistent POLIS Type (struct) is changed
/// either because of a side effect of other changes, or if the file or the remote cache was modified. The corresponding
/// `PersistentObject` decides to handle the notification by analysing the payload (the object type and id). The
/// corresponding stored properties are updated, and because `PersistentObject` is `Observable`, the UI View or the
/// server component are automatically notified.
struct PolisObjectDidChange: NotificationCenter.MainActorMessage {
    typealias Subject = ObjectStoreCoordinator

    let payload: PolisNotificationPayload

    init(_ payload: PolisNotificationPayload) { self.payload = payload }
}

/// This Notification Message is posted by a subclass of a `PersistentObject` when one or multiple properties are modified
/// either by a UI Client or a Server-side client. The `ObjectStoreCoordinator` handles the notification by first analysing
/// if other POLIS objects need to be modified, and then making the changes persistent. The `ObjectStoreCoordinator` might
/// decide to cache multiple notifications, and then to process them as a batch for performance reasons. If one
/// `PersistentObject` appears multiple times in the cache queue, only the last Notification Message is considered. From
/// time to time and after multiple changed notifications are handled, the changes will also be synced to the remote
/// POLIS Service Providers.
struct RepObjectDidChange: NotificationCenter.MainActorMessage {
    typealias Subject = PersistentObject

    let payload: IdentifiableObject

    init(_ payload: IdentifiableObject) { self.payload = payload }
}

/// This Notification Message is posted when a client (UI or Server app) is about to terminate. In order to prevent loss
/// of data, the corresponding client application should wait until it receives `PolisServiceProviderReadyToTerminate`
/// message.
struct PolisClientWillTerminate: NotificationCenter.MainActorMessage {
    typealias Subject = PersistentObject
}

/// This Notification Message is posted when all persistent data are stored locally and all syncing processes are finished.
/// **Note:** Normally, while syncing with remote provider, the Polis framework send Change Notification messages. During
/// the process of termination such messages are suppressed.
struct PolisServiceProviderReadyToTerminate: NotificationCenter.MainActorMessage {
    typealias Subject = ObjectStoreCoordinator
}


//
// ====================================================================================================================
//

// This below are discussion about how to implement the new Notification mechanism.

/*

 Intro written by Georg:
 WWe discussed, that the new (modern) type of Swift notifications will be used. I do find them clunky and definitely
not elegant, but my lady-colleagues (who were visiting the kindergarten when I was already using the notification pattern)
 did insist. So, how can one say "no" to lady- colleagues 😄

 The best (consistent) explanation of this modernism I found in this blogpost:
 https://fatbobman.com/en/posts/notificationcentermessage-a-new-concurrency-safe-notification-experience-in-swift-62/

 So, there are going to be two categories of notifications:
 - Sent by ObjectStoreController, when either the Controller itself, or external factors do change POLIS structs stored in
 JSON files. Example - The local store is synced with data from a remote Service Provider
 - Sent by Rep-type classes who represent the POLIS structures in a form, consumable for UI and Server-based clients of
 the framework. They will be sent (posted) when the UI-friendly class is changed and the changes do need to be reflected
 (made persistent) in the local Service provider and perhaps synced with a remote Service provider. In this case
 ObjectStoreController will consume this notifications, will calculate the reach of the change (in most cases - multiple
 POLIS struct and will make them persistent.

 Thoughts:
- It will make a lot of sense if the two type of notifications are standardised. This should include the payload (perhaps
 a single struct type, assuming the receivers are PolisObjectPersisting protocol compliant, or the operation type is
 defined in an enum (changed, deleted, created, ...). Ideally only a single Notification type will be defined, and the
 observer will be set in a superclass of the Rep-type classes. The same will be also valid for notifications addressed to
the ObjectStoreController.
- In order to be good citizens for UI Clients, the notifications should be posted to the @MainActor. This is ok, because
 UI changes could be performed rapidly, and persistency-related changes could run in separate Tasks.

 Here examples of few notifications:
 - ServiceProviderConfiguration didChanged / didCreate
 - PolisDirectory didChanged / didCreate
 - ObservingFacilitiesDirectory didChanged / didCreate

 - Facility didChanged / didCreate / didDelete
 - FacilityDetail didChanged / didCreate / didDelete
 - FacilityRep didChanged / didCreate / didDelete
 - FacilityDetailRep didChanged / didCreate / didDelete

 Ideally, instead of defining all sorts of similar notifications it will be more elegant solution to combine them in only
 two notification types:
 - PolisObjectDidChange and
 - RepObjectDidChange
 where the nature of the change, the type of the object, and the ID of the object are encapsulated within the notification.

 There are few very specialised notifications, like:
 - ClientWillTerminate
 - ServiceProviderReadyToTerminate
 These specialised notifications obviously will be encapsulated in their own Swift Types.
 */




/*
Zhanna's suggestions and questions

 Suggestion:
 1. Encapsulate NotificationCenter usage in a "Mediator" layer.
    So neither the Coordinator nor the Client will communicate directly with NotificationCenter.
    Also this makes it easy to replace "NotificationCenter.MainActorMessage" if needed.

 [GT] I am with mixed feelings. Mediator pattern work well when it is a bridge between two different functionality modules or
 domains. IMHO is is an overkill when all types "know" each-other and work in collaboration. In addition, this might
 introduce additional headaches of implementing Actors and async/await. On the other hand I was very
 disappointed with the Notification extensions in Swift 6.x and even discussed with Ani the possibility to use our
 Message Dispatching to replace it. Your suggestion is somehow close to our idea about Message Dispatching.

 2. Mediator's responsibilities:
 - abstracting and encapsulating NotificationCenter usage
 - transferring payloads between components without modifying the data
 - performing format(only) validation before dispatching the payload (e.g. non-empty identifiers)

 [GT] "performing format validation" -> this should be a responsibility of the corresponding type, because the type knows
 itself best. One of the super-powers of EOF is that every Enterprise Object does it's own validation in a well defined
 and standardised way. And one of Java's nightmares is that they do not do this, but have entire protocol and class
 hierarchy of messy and often useless formatters.

Questions:
 1. what should be in payload object?
    - action   // create / update / delete / load / ?
    - entity   // facility / artifact / serviceProviderConfiguration / ?
    - id       // object identifier (enum/string ?)
    - type     // command / event             // this could give a little more distinction or separation
                  - command: sent from UI
                  - event: sent from coordinator

[GT]
- entity -> entityType as an enum
- id: UUID (Identifiable protocol, makes it also Hashable in a trivial way
- type -> not needed. entityType and id are enough to uniquely identify any instance in the object hierarchy.

 2. when a client performs one action that updates several objects, what is the expected behaviour?
    — send individual notifications
    - send one combined notification (batch)
      Example:
        The client edited ObservingFacilityDetails.ObservingFacility.startTime.
        Who should receive the notification? (ObservingFacilityDetails / ObservingFacility)
        Should we also notify parent directories/metadata objects?

 [GT]
 - The way how Hasmik did design the app is one_polis_type-one_screen. When "Save" is pressed, the app quits, or the screen
 (view) is changed, the entire instance is marked as changed without any atomic level bookkeeping (e.g. only the name
 did change). This is faster and less complicated to implement. So, in a way there is an automatic packaging of changes.

 3. should there be a logic as a queue, in case when the request is in progress but the client asks again?

[GT] No. The MainActor dies serialise the calls and besides, it is too complicated. Future version of the Coordinator
might implement grouping of notification into a single detached Task.

 4. how the error case should look?
    - error types (failedToLoad / failedToSync / timeout / noInternet / unknown / ?)
    - should errors be sent as a separate message type (PolisErrorMessage), or as an event with action == error?

[GT] Good question, that might have different equivalently valid answers.
- The wise software engineers would tell you, that each notification should have an ID, and should be dequeued only when
"OK" was received. In practice I think this introduces an unnecessary complications.
 - The naive but more practical solution would be if the Coordinator tells directly the "client" instance that the last
 operation from certain type did fail.
 - Errors are supposed to happen extremely rarely. We do not care if the internet is down, because next time we use the
 app the internet presumably will be up. And how often is your file system full or damaged?
 - We might have some additional non-blocking warnings, that tell the user things like the data is not synced with the
 remote server.

 5. should the Client listen to all notifications and filter or should they subscribe only to their own entity/id?

 [GT] There are 3 possible implementations
 - Naive and somehow slow, but simple -> listen to all notifications
 - A bit faster, but more complex -> listen to notification only if the data is visible for the user
 - A bit faster, but even more complex -> listen only my own notifications.
 I would start with the first one, and if it degrades performance, will update to the second.

 6. does every entity support every action?
    Example:
      Can Client send .delete for artifact?
      Can Client send .delete for PolisDirectory?

 [GT] If the question is about client instances - yes. The Coordinator will ignore forbidden actions.

 7. should there be a special type of notifications without payload?
    Example:
      ClientWillTerminate
      ServiceProviderReadyToTerminate
      // probably the list will increase later
[GT] YES

 [GT] Summary: for the sake of simplicity, and because we really are running out of time, I would suggest we use
 Swift 6.x type MainActor notifications.

 */

/*

 Georg's suggestion for To Do list:

 Because we have to experiment with 3 new elements:
 - Swift 6.x async/await,
 - Swift 6.x Notifications, and
 - @Observable pattern (for the SwiftUI)

 I would like to suggest:
 - I will make ServiceProvider (the simplest and fully independent type) @Observable
 - Zhanna can experiment with create and didChange notifications
 - Hasmik can create a separate Window+ view for it's editing
 - And I will send notifications from the Coordinator and will handle the persistence.

 Does this sound as a plan?

 */
