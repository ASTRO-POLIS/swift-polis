//
//  PolisCommonTypes.swift
//  swift-polis
//
//  Created by Georg Tuparev on 19.02.25.
//

import Foundation

/// Defines the type to be used where to store local data the stored data
public enum PolisRepresentingStoredObjectType: Int, CaseIterable {
    case observingFacility // Cannot be shared, this is the facility Info (Details)
    case place             // Cannot be shared
    case observatory       // Can be shared
    case device            // Can be shared
    case artifact          // Cannot be shared
}


public enum PolisModeOfOperation: String, Codable {
    case manual
    case autonomous  // no dynamic schedular
    case remote
    case robotic
    case mixed       // e.g. in case of Network
    case other
    case unknown
}

public enum PolisElectromagneticSpectrumCoverage: String, Codable {
    case gammaRay      = "gamma_ray"
    case xRay          = "x_ray"
    case ultraviolet
    case optical
    case infrared
    case subMillimeter = "sub_millimeter"
    case radio
    case gravitational
    case other
    case unknown
    case neutrino
}

public enum PolisSorting {
    case none
    case dateAndTime
    case lastUpdated
}

