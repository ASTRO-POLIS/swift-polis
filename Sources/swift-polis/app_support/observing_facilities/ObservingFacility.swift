//
//  ObservingFacility.swift Persisting
//  swift-polis
//
//  Created by Georg Tuparev on 6.07.25.
//

import Foundation
import SoftwareEtudesUtilities

public class ObservingFacility: Persisting {

    //MARK: - Public APIs -

    // Identity related
    public var id: UUID
    public var externalReferences: [String]?
    public var lastUpdateTime: Date
    public var name: String?
    public var localName: String?
    public var abbreviation: String?
    public var shortDescription: String?
    public var startTime: Date?
    public var endTime: Date?
    public var polisRegistrationTime: Date?

    // ObservingFacilityReference related
    public var gravitationalBodyRelationship: PolisObservingFacilityLocationType
    public var placeInTheSolarSystem : PolisPlaceInTheSolarSystem

    public var observingFacilityDetails: ObservingFacilityDetails

    public internal(set) var isEditing = false

    //MARK: - Non-public APIs -
    let store: ObjectStore
    var identity: PolisIdentity {
        get {
            PolisIdentity(id: id,
                          externalReferences: externalReferences,
                          lastUpdateTime: lastUpdateTime,
                          name: name,
                          localName: localName,
                          abbreviation: abbreviation,
                          shortDescription: shortDescription,
                          startTime: startTime,
                          endTime: endTime,
                          polisRegistrationTime: polisRegistrationTime)
        }
        set {
            id                    = newValue.id
            externalReferences    = newValue.externalReferences
            lastUpdateTime        = newValue.lastUpdateTime
            name                  = newValue.name ?? "<unnamed>"
            localName             = newValue.localName
            abbreviation          = newValue.abbreviation
            shortDescription      = newValue.shortDescription
            startTime             = newValue.startTime
            endTime               = newValue.endTime
            polisRegistrationTime = newValue.polisRegistrationTime
        }
    }
    var facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference {
        get {
            PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity,
                                                                       gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                       placeInTheSolarSystem: placeInTheSolarSystem)
        }
        set {
            identity                      = newValue.identity
            gravitationalBodyRelationship = newValue.gravitationalBodyRelationship
            placeInTheSolarSystem         = newValue.placeInTheSolarSystem
        }
    }

    init(id: UUID,
         externalReferences: [String]?                                     = nil,
         lastUpdateTime: Date                                              = Date.now,
         name: String?                                                     = nil,
         localName: String?                                                = PolisConstants.unknownObject,
         abbreviation: String?                                             = nil,
         shortDescription: String?                                         = nil,
         startTime: Date?                                                  = nil,
         endTime: Date?                                                    = nil,
         polisRegistrationTime: Date?                                      = nil,
         gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed,
         placeInTheSolarSystem: PolisPlaceInTheSolarSystem                 = .earth,
         store: ObjectStore) throws {
        self.id                            = id
        self.externalReferences            = externalReferences
        self.lastUpdateTime                = lastUpdateTime
        self.name                          = name
        self.localName                     = localName
        self.abbreviation                  = abbreviation
        self.shortDescription              = shortDescription
        self.startTime                     = startTime
        self.endTime                       = endTime
        self.polisRegistrationTime         = polisRegistrationTime
        self.gravitationalBodyRelationship = gravitationalBodyRelationship
        self.placeInTheSolarSystem         = placeInTheSolarSystem
        self.store                         = store

        try self.observingFacilityDetails = ObservingFacilityDetails(id: id, lastUpdateTime: lastUpdateTime, name: self.name!)
    }

    init(facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference, store: ObjectStore) throws {
        self.id                            = facilityReference.identity.id
        self.externalReferences            = facilityReference.identity.externalReferences
        self.lastUpdateTime                = facilityReference.identity.lastUpdateTime
        self.name                          = facilityReference.identity.name ?? PolisConstants.unknownObject
        self.localName                     = facilityReference.identity.localName
        self.abbreviation                  = facilityReference.identity.abbreviation
        self.shortDescription              = facilityReference.identity.shortDescription
        self.startTime                     = facilityReference.identity.startTime
        self.endTime                       = facilityReference.identity.endTime
        self.polisRegistrationTime         = facilityReference.identity.polisRegistrationTime
        self.gravitationalBodyRelationship = facilityReference.gravitationalBodyRelationship
        self.placeInTheSolarSystem         = facilityReference.placeInTheSolarSystem
        self.store                         = store

        try self.observingFacilityDetails = ObservingFacilityDetails(id: id, lastUpdateTime: lastUpdateTime, name: self.name!)
    }

    //MARK: Private APIs -
    private let nc              = NotificationCenter.default
    private let fm              = FileManager.default
    private var isDir: ObjCBool = false
    private var jsonEncoder     = PrettyJSONEncoder()
    private var jsonDecoder     = PrettyJSONDecoder()
    private var jsonData: Data!
}

//MARK: - Persisting -
//TODO: Implement me!
//TODO: Implement doChange() to send change notification and set the date
extension ObservingFacility {
    public func canEdit() async -> Bool { await store.isEditable() }

    public func startEditing() async throws {
        if isEditing       { return }
        if await canEdit() { isEditing = true }
        else               { throw ObjectStore.ObjectStoreError.objectCannotBeEdited }
    }

    public func finishEditing() async throws { isEditing = false }

    public func saveChanges() async throws {
        // Make sure that the Details are saved. If they are changed, the details will change also the facility
        observingFacilityDetails.item.identity = self.identity
        try await observingFacilityDetails.saveChanges()

        if await didChange() {
            nc.post(name: AppSupportStatusChangeNotification.facilityWillSaveNotification, object: self)

            // Now make sure, that the Facility directory is updated
            try await store.addOrUpdateObservingFacilityDirectoryEntry(self)

            nc.post(name: AppSupportStatusChangeNotification.facilityDidSaveNotification, object: self)
        }
    }

    public func revertToSaved()                async throws { } //TODO: Implement me!
    public func delete()                       async throws { } //TODO: Implement me!

    public func loadData() async throws {
        nc.post(name: AppSupportStatusChangeNotification.facilityWillLoadNotification, object: self)

        Task {
            try await observingFacilityDetails.loadData()
        }
        // Note: if details are loaded successfully, they will send the FacilityDidChange notification!
    }

    public func didChange() async -> Bool {
        guard let referenceFacility = await store.facilityDirectory().facilityReferenceWith(id: self.id )
        else { return false }

        return referenceFacility != self.facilityReference
    }

    public func prepareToCloseTheObjectStore() async throws { } //TODO: Implement me!
}
