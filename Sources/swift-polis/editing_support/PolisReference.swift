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

    struct ReferencePrefixes {
        /// All remote references should start with this string
        ///
        /// The meaning of *remote* is defined elsewhere in the standard
        static let polisRemotePrefix = "remote://"

        /// All local references should start with this string
        ///
        /// The meaning of *local* is defined elsewhere in the standard
        static let polisLocalPrefix  = "local://"
    }

    var id: String
    var parentId: String?                           // e.g. observing facility
    var isShared: Bool
    var fileType: PolisImplementation.DataFormat

}
