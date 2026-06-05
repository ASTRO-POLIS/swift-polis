//
//  PlaceOnEarth.swift
//  swift-polis
//
//  Created by Georg Tuparev on 19.02.26.
//

import Foundation

//open class PlaceOnEarth: PolisObjectPersisting {
@Observable open class PlaceOnEarth: PersistentObject, Identifiable, Hashable, @unchecked Sendable {

    public internal(set) var id: UUID
    public internal(set) var lastUpdateTime: Date
    public internal(set) var facilityID: UUID // We need this because we need to know where to store the JSON file

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

    public var continent: PolisPlaceOnEarth.EarthContinent?

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

    //MARK: Make the class Hashable
    public static func == (lhs: PlaceOnEarth, rhs: PlaceOnEarth) -> Bool {  lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    //MARK: Internal APIs

    /// Instantiating a PlaceOnEarth object from a Police instance
    init(_ place: PolisPlaceOnEarth) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: place as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: place.id,
                                                                                                                 observingFacilityID: place.facilityID),
                                                                 objectType: .observingFacilityEarthFixedBasedDetails)
        self.id                 = place.id
        self.lastUpdateTime     = place.lastUpdateTime
        self.facilityID         = place.facilityID
        self.attentionOff       = place.attentionOff
        self.houseName          = place.houseName
        self.street             = place.street
        self.houseNumber        = place.houseNumber
        self.houseNumberSuffix  = place.houseNumberSuffix
        self.floor              = place.floor
        self.apartment          = place.apartment
        self.district           = place.district
        self.site               = place.site
        self.zipCode            = place.zipCode
        self.province           = place.province
        self.regionOrState      = place.regionOrState
        self.regionOrStateCode  = place.regionOrStateCode
        self.country            = place.country
        self.countryID          = place.countryID
        self.continent          = place.continent
        self.poBox              = place.poBox
        self.poBoxZip           = place.poBoxZip
        self.posteRestante      = place.posteRestante
        self.eastLongitude      = place.eastLongitude
        self.latitude           = place.latitude
        self.altitude           = place.altitude
        self.streetLine1        = place.streetLine1
        self.streetLine2        = place.streetLine2
        self.streetLine3        = place.streetLine3
        self.streetLine4        = place.streetLine4
        self.streetLine5        = place.streetLine5
        self.streetLine6        = place.streetLine6
        self.note               = place.note
        self.timeZoneIdentifier = place.timeZoneIdentifier

        await super.init(polisRep: sP)
    }

    /// Instantiating a new PlaceOnEarth instance
    init(facilityID: UUID) async {
        let fileResourceFinder                  = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        let polisObject                         = PolisPlaceOnEarth(facilityID: facilityID)
        let sP: PolisObjectRep<any PolisObject> = PolisObjectRep(polisObject: polisObject as any PolisObject,
                                                                 localPath: fileResourceFinder.observingDataFile(withID: polisObject.id,
                                                                                                                 observingFacilityID: facilityID),
                                                                 objectType: .placeOnEarth)

        self.id             = UUID()
        self.lastUpdateTime = Date.now
        self.facilityID     = facilityID

        await super.init(polisRep: sP)
    }

    var placeOnEarth: PolisPlaceOnEarth {
        PolisPlaceOnEarth(id: id,
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
    //MARK: Private APIs

    //MARK: - PolisObjectPersisting implementation -
    override func pathToLocalPolisFile() async -> String {
        let fileResourceFinder = await ObjectStoreCoordinator.shared.fileResourceFinder()!
        return fileResourceFinder.observingDataFile(withID: id, observingFacilityID: facilityID)
    }

    public override func markAsChanged() async throws { await setDidChange() }

    override func setDidChange() async {
        lastUpdateTime = Date.now
        _hasChanged    = true
        _polisRep.updateCurrentPolisObject(placeOnEarth)

        await ObjectStoreCoordinator.shared.didChange(object: self, ofType: .placeOnEarth)
    }
}
