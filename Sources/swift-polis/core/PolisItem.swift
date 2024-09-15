//
//  PolisItem.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20.08.24.
//

import Foundation

//MARK: - PolisLifecycleStatus -
/// The current status of the POLIS item (object) and its readiness to be used in different environments.
///
/// Each POLIS type (Provider, Observing Facility, Device, etc.) should include `LifecycleStatus` (as part of
/// ``PolisItem``).
///
/// `LifecycleStatus` will also determine the syncing policy as well as the visibility of the POLIS items within client
/// implementations. Implementations should adopt the following behaviours:
/// - `inactive`  - do not sync, but continue monitoring
/// - `active`    - must be synced and monitored
/// - `deleted`   - sync the `PolisItemAttributes` only to prevent secondary propagation of the item and to lock the
/// UUID of the item
///  - `historic` - do not sync, but continue monitoring
/// - `delete`    - delete the item
/// - `suspended` - sync the `PolisItemAttributes`, but do not use the service provider or the observing facility. Suspended
/// is used to mark that the item does not follow the POLIS standard, or violates community rules. Normally entities
/// will be warned first, and if they continue to break standards and rules, they will be deleted.
/// - `unknown`   - do not sync, but continue monitoring
public enum PolisLifecycleStatus: String, Codable {

    /// `inactive` indicates new, being edited, or in process of being upgraded by the provider(s).
    case inactive

    /// `active` indicates a production provider that is publicly accessible.
    case active

    /// Item still exists and has historical value but is not operational.
    case historic

    /// `deleted` is needed to prevent reappearance of disabled providers or facilities.
    case deleted

    /// After marking an item for deletion, wait for a year (check `lastUpdate`) and start marking the item as
    /// `delete`. After 18 months, remove the deleted items. It is assumed that 1.5 years is enough for all providers
    /// to mark the corresponding item as deleted.
    case delete

    /// `suspended` indicates providers violating the standard (temporary or permanently).
    case suspended

    /// `unknown` indicates a provider with unknown status, and is mostly used when the observing facility or instrument has
    /// unknown status.
    case unknown
}


public struct PolisItem: Codable {
    /// A type that describes the different kinds of owners of a POLIS item.

    public struct Owner: Codable {
        public var ownershipType: PolisOrganisationType
        public var personalOwnerIDs: Set<UUID>?
        public var organisationalOwnerIDs: Set<UUID>?
   }

    public var identity: PolisIdentity
    public var owner: Owner?

    public var parentID: UUID?

    /// The purpose of the optional `automationLabel` is to act as a unique target for scripts and other software
    /// packages. As an example, the observatory control software could search for an instrument with a given label and
    /// set its status or issue commands etc. This could be used to sync with ASCOM or INDI based systems.
    public var automationLabel: String?

    public          func childrenIDs() -> Set<UUID> { _childrenIDs }
    public mutating func addChildWith(id: UUID)     { _childrenIDs.insert(id) }
    public mutating func removeChildWith(id: UUID)  { _childrenIDs.remove(id) }

    //MARK: - Private properties
    private var _childrenIDs = Set<UUID>()
}
