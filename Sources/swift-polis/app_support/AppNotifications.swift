//
//  AppNotifications.swift
//  swift-polis
//
//  Created by Georg Tuparev on 24.02.26.
//

import Foundation

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

 Suggestion:
 1. Encapsulate NotificationCenter usage in a "Mediator" layer.
    So neither the Coordinator nor the Client will communicate directly with NotificationCenter.
    Also this makes it easy to replace "NotificationCenter.MainActorMessage" if needed.
 2.

 Mediator's responsibilities:
 - abstracting and encapsulating NotificationCenter usage
 - transferring payloads between components without modifying the data
 - performing format(only) validation before dispatching the payload (e.g. non-empty identifiers)


Questions:
 1. what should be in payload object?
    - action   // create / update / delete / load / ?
    - entity   // facility / artifact / serviceProviderConfiguration / ?
    - id       // object identifier (enum/string ?)
    - type     // command / event             // this could give a little more distinction or separation
                  - command: sent from UI
                  - event: sent from coordinator

 2. when a client performs one action that updates several objects, what is the expected behavior?
    — send individual notifications
    - send one combined notification (batch)
      Example:
        The client edited ObservingFacilityDetails.ObservingFacility.startTime.
        Who should receive the notification? (ObservingFacilityDetails / ObservingFacility)
        Should we also notify parent directories/metadata objects?

 3. should there be a logic as a queue, in case when the request is in progress but the client asks again?

 4. how the error case should look?
    - error types (failedToLoad / failedToSync / timeout / noInternet / unknown / ?)
    - should errors be sent as a separate message type (PolisErrorMessage), or as an event with action == error?

 5. should the Client listen to all notifications and filter or should they subscribe only to their own entity/id?

 6. does every entity support every action?
    Example:
      Can Client send .delete for artifact?
      Can Client send .delete for PolisDirectory?

 7. should there be a special type of notifications without payload?
    Example:
      ClientWillTerminate
      ServiceProviderReadyToTerminate
      // probably the list will increase later


 */
