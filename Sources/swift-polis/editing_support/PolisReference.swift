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

    static var polisFileResourceFinder: PolisFileResourceFinder!
    static var polisRemoteResourceFinder: PolisRemoteResourceFinder!
    static var auxiliaryServiceHosts = [String : String]()
    static var remoteWriteAPI: String?


    enum PolisReferenceError: Error {
        case classNotInitialised
        case referenceTypeNotImplemented
    }

    var localPath: String!
    var remoteReadPath: String!
    var remoteWriteAPI: String? // Basically a push (PUT) remote API with body of the corresponding JSON representation

    var isReferenced = false
    var hasLocalCopy = false

    var representingStoredObjectType: PolisRepresentingStoredObjectType
    var fileType: PolisImplementation.DataFormat

    init(id: UUID,
         isReferenced: Bool = false,
         hasLocalCopy: Bool = false,
         representingStoredObjectType: PolisRepresentingStoredObjectType = .observingFacility,
         fileType: PolisImplementation.DataFormat = .json) throws {

        if let polisFileResourceFinder = PolisReference.polisFileResourceFinder, let polisRemoteResourceFinder = PolisReference.polisRemoteResourceFinder {
            let idString = id.uuidString
            let fileName = "\(idString)/\(idString).\(fileType)"

            switch representingStoredObjectType {
                case .observingFacility:
                    localPath      = "\(polisFileResourceFinder.observingFacilitiesFolder())\(fileName)"
                    remoteReadPath = "\(polisRemoteResourceFinder.polisProviderDirectoryURL())\(fileName)"
                default: throw PolisReferenceError.referenceTypeNotImplemented
            }

            self.isReferenced = isReferenced
            self.hasLocalCopy = hasLocalCopy
            self.representingStoredObjectType = representingStoredObjectType
            self.fileType = fileType
        }
        else { throw PolisReferenceError.classNotInitialised }
    }
}
