//
//  PolisReference.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.05.25.
//

import Foundation

public struct PolisReference {

    public static var remoteServiceProvider = PolisConstants.bigBangPolisDomain
    public static var auxiliaryServiceHosts = [String : String]()

    public struct ReferencePrefixes {
        /// All remote references should start with this string
        ///
        /// The meaning of *remote* is defined elsewhere in the standard
        public static let polisRemotePrefix     = "remote://"

        /// All local references should start with this string
        ///
        /// The meaning of *local* is defined elsewhere in the standard
        public static let polisLocalPrefix         = "local://"


    }
    public enum ReferenceKind {
        case localCopy
        case owner
        case manufacturer
    }

    public var id: UUID
    public var kind: ReferenceKind
    public var fileType: PolisImplementation.DataFormat
}
