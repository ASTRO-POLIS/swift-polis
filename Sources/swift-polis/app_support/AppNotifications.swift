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

