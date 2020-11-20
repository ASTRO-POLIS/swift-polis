//
//  ObservingSite.swift
//  
//
//  Created by Georg Tuparev on 20/11/2020.
//

import Foundation

public enum ObservingSiteType: String, Codable {
    case groundBasedFixed
    case groundBasedMobile
    case space   //TODO: Find a better name
}

public struct ObservingSite: Codable {
    // Location
    public let name: String
    public let startDate: Date
    public let endDate: Date?   // if != nil -> either closed or temporary created (e.g. solar eclipse monitoring)
}

public struct Observatory {
    // Location
}

public enum InstrumentType {
    case telescope(Telescope)
    case radioAntenna(RadioAntenna)
}

public struct Telescope {
    // Aperture
    // Camera
    public let description: String?
    // FocalLength
    // FocalRatio
    // Mirrors
    // SpectralEfficiency
    // SpectralRegion
    // TrackRate
    public let instruments: [InstrumentType]?
}

public struct RadioAntenna {

}
