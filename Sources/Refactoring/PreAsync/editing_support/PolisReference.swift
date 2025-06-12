//
//  PolisReference.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.05.25.
//

import Foundation

// Note: The use of `PolisReference` assumes, that the Directory type data is always stored locally
// (but allow for out-of-sync) with remote directory data!

struct PolisReference {

//    static var polisFileResourceFinder: PolisFileResourceFinder!
//    static var polisRemoteResourceFinder: PolisRemoteResourceFinder!
//    static var auxiliaryServiceHosts = [String : String]()
//    static var remoteWriteAPI: String?

    enum DataExistenceStatus {
        case unknown
        case notCreated
        case created
    }

    enum DataLoadingStatus {
        case unknown
        case notLoaded
        case loadedNotSynced
        case loadedSynced
    }

    struct DataEntryStatus {
        var existenceStatus: DataExistenceStatus
        var loadingStatus: DataLoadingStatus
    }

    struct DataStatus {
        var existenceStatusLocal  = DataExistenceStatus.unknown
        var existenceStatusRemote = DataExistenceStatus.unknown
        var loadingStatus         = DataLoadingStatus.unknown
    }

    enum PolisReferenceError: Error {
        case classNotInitialised
        case referenceTypeNotImplemented
        case missingFacilityID
    }


//    var localPath: String!
//    var remoteReadPath: String!
//    var remoteWriteAPI: String? // Basically a push (PUT) remote API with body of the corresponding JSON representation

    var isReferenced = false
    var hasLocalCopy = false

    var representingStoredObjectType: PolisRepresentingStoredObjectType
    var fileType: PolisImplementation.DataFormat

    var dataStatus = DataStatus()

    init(facilityID: UUID?,
         polisObjectID: UUID,
         isReferenced: Bool = false,
         hasLocalCopy: Bool = false,
         representingStoredObjectType: PolisRepresentingStoredObjectType = .observingFacility,
         fileType: PolisImplementation.DataFormat = .json) throws {
        if let polisFileResourceFinder = PolisReference.polisFileResourceFinder, let polisRemoteResourceFinder = PolisReference.polisRemoteResourceFinder {
            let facilityIDString = facilityID?.uuidString
            let polisIdString    = polisObjectID.uuidString

            switch representingStoredObjectType {
                case .observingFacility:
                    if let facilityIDString = facilityIDString {
                        let fileName   = "\(facilityIDString)/\(polisIdString).\(fileType)"

                        localPath      = "\(polisFileResourceFinder.observingFacilitiesFolder())\(fileName)"
                        remoteReadPath = "\(polisRemoteResourceFinder.polisProviderDirectoryURL())\(fileName)"
                    }
                    else { throw PolisReferenceError.missingFacilityID }
                case .artifact:
                    if let facilityID = facilityID {
                        let fileName   = "\(polisIdString).\(fileType)"

                        localPath      = "\(polisFileResourceFinder.observingFacilityFolder(observingFacilityID: facilityID))\(fileName)"
                        remoteReadPath = "\(polisRemoteResourceFinder.observingFacilityURL(observingFacilityID: facilityID))\(fileName)"
                    }
                    else { throw PolisReferenceError.missingFacilityID }
                default: throw PolisReferenceError.referenceTypeNotImplemented
            }

            self.isReferenced                 = isReferenced
            self.hasLocalCopy                 = hasLocalCopy
            self.representingStoredObjectType = representingStoredObjectType
            self.fileType                     = fileType
            self._isLocked                    = false
        }
        else { throw PolisReferenceError.classNotInitialised }
    }

    //FIXME:  This is a naive implementation of locking that is good enough for now, but need to be changed for Swift 6!
    func canEdit() -> Bool { !_isLocked }
    mutating func startEditing()  { _isLocked = true }
    mutating func finishEditing() { _isLocked = false }

    //MARK: Private APIs
    private var _isLocked = true
}
