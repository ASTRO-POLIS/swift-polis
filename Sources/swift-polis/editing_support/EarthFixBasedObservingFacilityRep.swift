//
//  EarthFixBasedObservingFacilityRep.swift
//  swift-polis
//
//  Created by Georg Tuparev on 23/10/2024.
//

import Foundation

open class EarthFixBasedObservingFacilityRep: ObservingFacilityRep {

    //MARK: Public APIs

    // Address related
    public var street: String?
    public var houseNumber: Int?
    public var houseNumberSuffix: String?
    public var district: String?
    public var place: String?                     // e.g. Mount Wilson
    public var zipCode: String?
    public var province: String?
    public var regionOrState: String?             // Region or state name, e.g. California
    public var regionOrStateCode: String?         // e.g. CA for California

    public var country: String?                   // e.g. Armenia
    public var countryID: String?                 // 2-letter code

    public var continent: PolisPlace.EarthContinent?

    public var eastLongitude: PolisPropertyValue? // degrees
    public var latitude: PolisPropertyValue?      // degrees
    public var altitude: PolisPropertyValue?      // m

    public var addressNote: String?

    public var timeZoneIdentifier: String?        // .. as defined with `TimeZone.knownTimeZoneIdentifiers`

    // General info
    public var visitingHours: PolisVisitingHours?
    public var accessRestrictions: String?

    public var averageClearNightsPerYear: UInt?
    public var averageSeeingConditions: PolisPropertyValue? // [arcsec]
    public var averageSkyQuality: PolisPropertyValue?       // [magnitude / arcsec^2]

    public var traditionalLandOwners: String?

    public var dominantWindDirection: PolisDirection.RoughDirection?
    public var surfaceSize: PolisPropertyValue?             // [m^2]

    //MARK: - PolisPersisting implementation -
    public override func saveChanges() throws {
        try super.saveChanges()

        //TODO: Implement me!

        // 1. Check if I exist as POLIS file, and if not, create myself

        // 2. Check if I did changed

        // 3. If I changed,
        // 3.1. Update `super` properties and called the super's `saveChanges()`
        // 3.1. Update PolisObservingFacilityLocation file
        // 3.2. Update the POLIS cache in Provider Manager
        // 3.3. Update the provider directory cache in Provider Manager
    }

    public override func revertToSaved() throws {
        //TODO: Implement me!
    }

    public override func delete() throws {
        //TODO: Implement me!
    }

    public override func didChange() -> Bool {
        //TODO: Implement me!
        false
    }


    //MARK: Non-private APIs
    static func registerFacilityWithExisting(identity: PolisIdentity) throws -> ObservingFacilityRep {
        //TODO: Implement me!
       throw ObservingFacilityRepError.unavailableOrUnreadableLocalData
    }

    static func createObservingFacilityFrom(details: PolisObservingFacility) {
        //TODO: Implement me!
    }

//    public static func createEarthFixBasedFacility(with id: UUID                 = UUID(),
//                                                   externalReferences: [String]? = nil,
//                                                   lastUpdateDate: Date          = Date(),
//                                                   name: String                  = "Unknown Facility",
//                                                   localName: String?            = nil,
//                                                   abbreviation: String?         = nil,
//                                                   shortDescription: String?     = nil,
//                                                   startDate: Date?              = nil,
//                                                   endDate: Date?                = nil,
//                                                   polisRegistrationDate: Date?  = nil) throws -> EarthFixBasedObservingFacilityRep {
//        let nc       = NotificationCenter.default
//        let provider = PolisProviderManager.currentProviderManager!
//
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillCreateNotification, object: nil)
//
//        let result   = try EarthFixBasedObservingFacilityRep.registerNewEarthFixBasedFacility(with: id,
//                                                                                              externalReferences: externalReferences,
//                                                                                              lastUpdateDate: lastUpdateDate,
//                                                                                              name: name,
//                                                                                              localName: localName,
//                                                                                              abbreviation: abbreviation,
//                                                                                              shortDescription: shortDescription,
//                                                                                              startDate: startDate,
//                                                                                              endDate: endDate,
//                                                                                              polisRegistrationDate: polisRegistrationDate)
//
//        try provider.flush(item: provider.facilityDirectory)
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidCreateNotification, object: result)
//
//        return result
//    }



    /// Tries to register a new Earth-based facility
    /// 
    /// - Parameters:
    ///   - id: the unique facility id. If not provided will be autogenerated
    ///   - externalReferences: references to external items
    ///   - lastUpdateDate: when the facility is modified last
    ///   - name: although not required, it is recommended, that the name is unique. This will provide more meaningful search and discovery functionality
    ///   - localName: good for localisation
    ///   - abbreviation: astronomers gave strange abbreviations
    ///   - shortDescription: short description of the facility
    ///   - startDate: when the facility was created
    ///   - endDate: the date in case the facility does not exist any more
    ///   - polisRegistrationDate: when the facility was introduced to POLIS
    ///   - shouldCreateNewEntity: if `true` then the facility will be written to the local file system
    /// - Returns: newly registered facility
    /// 
//    public static func registerNewEarthFixBasedFacility(with id: UUID                 = UUID(),
//                                                        externalReferences: [String]? = nil,
//                                                        lastUpdateDate: Date          = Date(),
//                                                        name: String                  = "Unknown Facility",
//                                                        localName: String?            = nil,
//                                                        abbreviation: String?         = nil,
//                                                        shortDescription: String?     = nil,
//                                                        startDate: Date?              = nil,
//                                                        endDate: Date?                = nil,
//                                                        polisRegistrationDate: Date?  = nil) throws -> EarthFixBasedObservingFacilityRep {
//        //TODO: Check if this is true (In case facility with the same `id` already exists, `facilityAlreadyExists` is thrown)
//        let provider                 = PolisProviderManager.currentProviderManager!
//        let result                   = EarthFixBasedObservingFacilityRep(id: id, name: name)
//        let nc                       = NotificationCenter.default
//
//        result.externalReferences    = externalReferences
//        result.lastUpdateDate        = lastUpdateDate
//        result.localName             = localName
//        result.abbreviation          = abbreviation
//        result.shortDescription      = shortDescription
//        result.startDate             = startDate
//        result.endDate               = endDate
//        result.polisRegistrationDate = polisRegistrationDate
//
//        let dirEntry                 = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: result.identity)
//
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillCreateNotification, object: nil)
//        provider.facilityDirectory.addOrUpdateObservingFacility(reference: dirEntry)
//        provider.facilities.append(result)
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidCreateNotification, object: result)
//
//        return result
//    }
    
    /// This method could be used either when locally stored POLIS facility data are read, or when the data are downloaded from a remote server.
    ///
    /// The POLIS data will be transferred into equivalent Rep class and registered to the Provider manager. Corresponding notifications will be posted.
    ///
    /// - Parameter polisData: hopefully correct facility data
    ///   - shouldCreateNewEntity: if `true` then the facility will be written to the local file system
    /// - Returns: `EarthFixBasedObservingFacilityRep` object if the POLIS data is from the correct type/
//    public static func registerNewEarthBasedFacilityFrom(polisData: PolisObservingFacility,
//                                                         shouldCreateNewEntity: Bool = false) throws -> EarthFixBasedObservingFacilityRep {
//        let provider = PolisProviderManager.currentProviderManager!
//        let nc       = NotificationCenter.default
//        let result   = try createEarthFixBasedFacility(with: polisData.id,
//                                                       externalReferences: polisData.item.identity.externalReferences,
//                                                       lastUpdateDate: polisData.item.identity.lastUpdateDate,
//                                                       name: polisData.item.identity.name,
//                                                       localName: polisData.item.identity.localName,
//                                                       abbreviation: polisData.item.identity.abbreviation,
//                                                       shortDescription: polisData.item.identity.shortDescription,
//                                                       startDate: polisData.item.identity.startDate,
//                                                       endDate: polisData.item.identity.endDate,
//                                                       polisRegistrationDate: polisData.item.identity.polisRegistrationDate)

//        // First check if we are getting correct data - should be from Earth and fixed based
//        if (polisData.placeInTheSolarSystem != .earth) || (polisData.gravitationalBodyRelationship != .surfaceFixed) {
//            PolisLogger.shared.error("Wrong POLIS data type received! Expended Earth based fixed facility")
//            throw PolisProviderManager.PolisProviderManagerError.polisDataMismatch
//        }
//
//        // Announce that we will start loading the facility data
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoWillCreateNotification, object: nil)
//
//        //TODO: Now set local properties
//        result.item = polisData.item      // Everything we need for the POLIS item
//
//        //TODO: ... and now somehow we need here the location...
//
//        //TODO: Register the object into the global list of facilities
//
//        // Register notifications
//        nc.post(name: PolisProviderManager.StatusChangeNotification.facilityInfoDidCreateNotification, object: result)
//
//        return result
//    }

//    /// Used to register facilities from existing local data
//    ///
//    /// This method is used internally only
//    static func registerEarthFixBasedFacility(with identity: PolisIdentity) throws  {
//        _ = try EarthFixBasedObservingFacilityRep.registerNewEarthFixBasedFacility(with: identity.id,
//                                                                                   externalReferences: identity.externalReferences,
//                                                                                   lastUpdateDate: identity.lastUpdateDate,
//                                                                                   name: identity.name,
//                                                                                   localName: identity.localName,
//                                                                                   abbreviation: identity.abbreviation,
//                                                                                   shortDescription: identity.shortDescription,
//                                                                                   startDate: identity.startDate,
//                                                                                   endDate: identity.endDate,
//                                                                                   polisRegistrationDate: identity.polisRegistrationDate)
//    }

    override init(id: UUID, lastUpdateDate: Date = Date(), name: String) {
        super.init(id: id, lastUpdateDate: lastUpdateDate, name: name)

        self.gravitationalBodyRelationship = .surfaceFixed
        self.placeInTheSolarSystem = .earth
    }

//    init(id: UUID,
//         name: String,
//         street: String?                                       = nil,
//         houseNumber: Int?                                     = nil,
//         houseNumberSuffix: String?                            = nil,
//         district: String?                                     = nil,
//         place: String?                                        = nil,
//         zipCode: String?                                      = nil,
//         province: String?                                     = nil,
//         regionOrState: String?                                = nil,
//         regionOrStateCode: String?                            = nil,
//         country: String?                                      = nil,
//         countryID: String?                                    = nil,
//         continent: PolisPlace.EarthContinent?                 = nil,
//         eastLongitude: PolisPropertyValue?                    = nil,
//         latitude: PolisPropertyValue?                         = nil,
//         altitude: PolisPropertyValue?                         = nil,
//         addressNote: String?                                  = nil,
//         timeZoneIdentifier: String?                           = nil,
//         visitingHours: PolisVisitingHours?                    = nil,
//         accessRestrictions: String?                           = nil,
//         averageClearNightsPerYear: UInt?                      = nil,
//         averageSeeingConditions: PolisPropertyValue?          = nil,
//         averageSkyQuality: PolisPropertyValue?                = nil,
//         traditionalLandOwners: String?                        = nil,
//         dominantWindDirection: PolisDirection.RoughDirection? = nil,
//         surfaceSize: PolisPropertyValue?                      = nil) {
//        self.street                    = street
//        self.houseNumber               = houseNumber
//        self.houseNumberSuffix         = houseNumberSuffix
//        self.district                  = district
//        self.place                     = place
//        self.zipCode                   = zipCode
//        self.province                  = province
//        self.regionOrState             = regionOrState
//        self.regionOrStateCode         = regionOrStateCode
//        self.country                   = country
//        self.countryID                 = countryID
//        self.continent                 = continent
//        self.eastLongitude             = eastLongitude
//        self.latitude                  = latitude
//        self.altitude                  = altitude
//        self.addressNote               = addressNote
//        self.timeZoneIdentifier        = timeZoneIdentifier
//        self.visitingHours             = visitingHours
//        self.accessRestrictions        = accessRestrictions
//        self.averageClearNightsPerYear = averageClearNightsPerYear
//        self.averageSeeingConditions   = averageSeeingConditions
//        self.averageSkyQuality         = averageSkyQuality
//        self.traditionalLandOwners     = traditionalLandOwners
//        self.dominantWindDirection     = dominantWindDirection
//        self.surfaceSize               = surfaceSize
//
//        super.init(id: id, name: name)
//    }

//    func setIdentity( _ identity: PolisIdentity, isNewValue: Bool = false) {
//        id                 = identity.id
//        externalReferences = identity.externalReferences
//        lastUpdateDate     = identity.lastUpdateDate
//        name               = identity.name
//        localName          = identity.localName
//        abbreviation       = identity.abbreviation
//        shortDescription   = identity.shortDescription
//        startDate          = identity.startDate
//        endDate            = identity.endDate
////        identityDidChange  = isNewValue
//    }

    //TODO: Implement me!
//    convenience init(identity: PolisIdentity) {
//    }

    //TODO: Implement me!
//    convenience init(item: PolisItem) {
//    }



}
