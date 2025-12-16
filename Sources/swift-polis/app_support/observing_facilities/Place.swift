//
//  Place.swift
//  swift-polis
//
//  Created by Georg Tuparev on 30.05.25.
//

import Foundation

public actor Place: @preconcurrency Persisting, Sendable {

    public var persistentObject: PersistentObject
    public var persistenceDescriptor: PersistenceDescriptor

    public var attentionOff: String?
    public var houseName: String?
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var floor: Int?
    public var apartment: String?
    public var district: String?
    public var site: String?                      // e.g. Mount Wilson
    public var block: String?
    public var zipCode: String?
    public var province: String?
    public var regionOrState: String?             // Region or state name, e.g. California
    public var regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: PolisPlace.EarthContinent?

    public var poBox: String?
    public var poBoxZip: String?

    public var posteRestante: String?

    public var eastLongitude: PolisPropertyValue? // degrees
    public var latitude: PolisPropertyValue?      // degrees
    public var altitude: PolisPropertyValue?      // m

    public var streetLine1: String?
    public var streetLine2: String?
    public var streetLine3: String?
    public var streetLine4: String?
    public var streetLine5: String?
    public var streetLine6: String?

    public var note: String?

    public var timeZoneIdentifier: String?        // .. as defined with `TimeZone.knownTimeZoneIdentifiers`

    //MARK: - Non-public APIs -
    var facilityID: UUID
    var place: PolisPlace {
        get {
            PolisPlace(id: id,
                       lastUpdateTime: lastUpdateTime,
                       facilityID: facilityID,
                       attentionOff: attentionOff,
                       houseName: houseName,
                       street: street,
                       houseNumber: houseNumber,
                       houseNumberSuffix: houseNumberSuffix,
                       floor: floor,
                       apartment: apartment,
                       district: district,
                       site: site,
                       block: block,
                       zipCode: zipCode,
                       province: province,
                       regionOrState: regionOrState,
                       regionOrStateCode: regionOrStateCode,
                       country: country,
                       countryID: countryID,
                       continent: continent,
                       poBox: poBox,
                       poBoxZip: poBoxZip,
                       posteRestante: posteRestante,
                       eastLongitude: eastLongitude,
                       latitude: latitude,
                       altitude: altitude,
                       streetLine1: streetLine1,
                       streetLine2: streetLine2,
                       streetLine3: streetLine3,
                       streetLine4: streetLine4,
                       streetLine5: streetLine5,
                       streetLine6: streetLine6,
                       note: note,
                       timeZoneIdentifier: timeZoneIdentifier)
        }
        set {
            persistentObject.id             = newValue.id
            persistentObject.lastUpdateTime = newValue.lastUpdateTime
            facilityID                      = newValue.facilityID
            attentionOff                    = newValue.attentionOff
            houseName                       = newValue.houseName
            street                          = newValue.street
            houseNumber                     = newValue.houseNumber
            houseNumberSuffix               = newValue.houseNumberSuffix
            floor                           = newValue.floor
            apartment                       = newValue.apartment
            district                        = newValue.district
            site                            = newValue.site
            block                           = newValue.block
            zipCode                         = newValue.zipCode
            province                        = newValue.province
            regionOrState                   = newValue.regionOrState
            regionOrStateCode               = newValue.regionOrStateCode
            country                         = newValue.country
            countryID                       = newValue.countryID
            continent                       = newValue.continent
            poBox                           = newValue.poBox
            poBoxZip                        = newValue.poBoxZip
            posteRestante                   = newValue.posteRestante
            eastLongitude                   = newValue.eastLongitude
            latitude                        = newValue.latitude
            altitude                        = newValue.altitude
            streetLine1                     = newValue.streetLine1
            streetLine2                     = newValue.streetLine2
            streetLine3                     = newValue.streetLine3
            streetLine4                     = newValue.streetLine4
            streetLine5                     = newValue.streetLine5
            streetLine6                     = newValue.streetLine6
            note                            = newValue.note
            timeZoneIdentifier              = newValue.timeZoneIdentifier
        }
    }

    public var id: UUID { persistentObject.id }
    public var lastUpdateTime: Date {
        get { persistentObject.lastUpdateTime }
        set { persistentObject.lastUpdateTime = newValue }
    }
    public var lifecycleStatus: PolisLifecycleStatus {
        get { persistentObject.lifecycleStatus }
        set { persistentObject.lifecycleStatus = newValue }
    }

    public var isEditing: Bool = false

    init(id: UUID                              = UUID(),
         lastUpdateTime: Date                  = Date.now,
         attentionOff: String?                 = nil,
         houseName: String?                    = nil,
         street: String?                       = nil,
         houseNumber: Int?                     = nil,
         houseNumberSuffix: String?            = nil,
         floor: Int?                           = nil,
         apartment: String?                    = nil,
         district: String?                     = nil,
         site: String?                         = nil,
         block: String?                        = nil,
         zipCode: String?                      = nil,
         province: String?                     = nil,
         regionOrState: String?                = nil,
         regionOrStateCode: String?            = nil,
         country: String?                      = nil,
         countryID: String?                    = nil,
         continent: PolisPlace.EarthContinent? = nil,
         poBox: String?                        = nil,
         poBoxZip: String?                     = nil,
         posteRestante: String?                = nil,
         eastLongitude: PolisPropertyValue?    = nil,
         latitude: PolisPropertyValue?         = nil,
         altitude: PolisPropertyValue?         = nil,
         streetLine1: String?                  = nil,
         streetLine2: String?                  = nil,
         streetLine3: String?                  = nil,
         streetLine4: String?                  = nil,
         streetLine5: String?                  = nil,
         streetLine6: String?                  = nil,
         note: String?                         = nil,
         timeZoneIdentifier: String?           = nil,
         facilityID: UUID) throws {
        self.persistentObject   = PersistentObject(id: id, lastUpdateTime: lastUpdateTime, lifecycleStatus: .active)
        self.facilityID         = facilityID
        self.attentionOff       = attentionOff
        self.houseName          = houseName
        self.street             = street
        self.houseNumber        = houseNumber
        self.houseNumberSuffix  = houseNumberSuffix
        self.floor              = floor
        self.apartment          = apartment
        self.district           = district
        self.site               = site
        self.block              = block
        self.zipCode            = zipCode
        self.province           = province
        self.regionOrState      = regionOrState
        self.regionOrStateCode  = regionOrStateCode
        self.country            = country
        self.countryID          = countryID
        self.continent          = continent
        self.poBox              = poBox
        self.poBoxZip           = poBoxZip
        self.posteRestante      = posteRestante
        self.eastLongitude      = eastLongitude
        self.latitude           = latitude
        self.altitude           = altitude
        self.streetLine1        = streetLine1
        self.streetLine2        = streetLine2
        self.streetLine3        = streetLine3
        self.streetLine4        = streetLine4
        self.streetLine5        = streetLine5
        self.streetLine6        = streetLine6
        self.note               = note
        self.timeZoneIdentifier = timeZoneIdentifier
        self.facilityID         = facilityID

        persistentObject        = PersistentObject(id             : id,
                                                   lastUpdateTime : lastUpdateTime,
                                                   lifecycleStatus: .active)
        persistenceDescriptor   = PersistenceDescriptor(representingStoredObjectType: .place,
                                                   fileType       : PolisImplementation.DataFormat.json,
                                                   facilityID     : facilityID)
    }
}

//MARK:  - Implementations for Persisting protocol -
extension Place {
    public func canEdit()                      async -> Bool { false } // Better be on the safe side
//    public func startEditing()                 async throws { }
//    public func finishEditing()                async throws { }

    public func saveChanges()                  async throws { }  //TODO: Implement me!!
    public func revertToSaved()                async throws { }  //TODO: Implement me!!
    public func delete()                       async throws { }  //TODO: Implement me!!
    public func loadData()                     async throws { }  //TODO: Implement me!!

    public func didChange()                    async -> Bool { false }   //TODO: Implement me!!

    public func prepareToCloseTheObjectStore() async throws { }   //TODO: Implement me!!
}
