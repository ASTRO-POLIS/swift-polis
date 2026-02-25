//
//  ObservingFacility.swift
//  swift-polis
//
//  Created by Georg Tuparev on 16.01.26.
//

import Foundation

@Observable public class ObservingFacility: Identifiable {

    public var facilityIdentity: IdentifiableObject
    public var gravitationalBodyRelationship: PolisObservingFacilityLocationType = .surfaceFixed
    public var placeInTheSolarSystem : PolisPlaceInTheSolarSystem                = .earth

    public var id: UUID { facilityIdentity.id }

    //TODO: Here we need to list additional objects like Details, Artifacts, Locations, SubFacilities, Observatories, and Devices. All of them should be optional

    public init(facilityIdentity: IdentifiableObject,
                gravitationalBodyRelationship: PolisObservingFacilityLocationType,
                placeInTheSolarSystem: PolisPlaceInTheSolarSystem) {
        self.facilityIdentity              = facilityIdentity
        self.gravitationalBodyRelationship = gravitationalBodyRelationship
        self.placeInTheSolarSystem         = placeInTheSolarSystem
    }

    //MARK: Internal APIs

    var facilityReference: PolisObservingFacilityDirectory.ObservingFacilityReference {
        PolisObservingFacilityDirectory.ObservingFacilityReference(identity: facilityIdentity.identity,
                                                                   gravitationalBodyRelationship: gravitationalBodyRelationship,
                                                                   placeInTheSolarSystem: placeInTheSolarSystem)
    }
}

