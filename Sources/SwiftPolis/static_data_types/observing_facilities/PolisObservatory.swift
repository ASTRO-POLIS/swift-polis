//
//  PolisObservatory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 08/11/2024.
//

import Foundation

public class PolisObservatory: Identifiable, Codable {

    public enum ObservatoryType: String, Codable {
        case single
        case array          // Many things of a similar type on the same place
        case interferometer // An array of observatories working together
        case network        // Many usually single observatories
        case mixed
        case other
        case unknown
    }

    public var identity: PolisIdentity
    public var electromagneticSpectrumCoverage: [PolisElectromagneticSpectrumCoverage]?
    public var observatoryType: ObservatoryType

    public var location: PolisPlaceOnEarth?

    public var configurationIDs: Set<UUID>?
    public var deviceIDs: Set<UUID>?

    public var id: UUID { identity.id }

    public init(identity: PolisIdentity,
                electromagneticSpectrumCoverage: [PolisElectromagneticSpectrumCoverage]? = nil,
                observatoryType: ObservatoryType                                         = .unknown,
                location: PolisPlaceOnEarth?                                             = nil,
                configurationIDs: Set<UUID>?                                             = nil,
                deviceIDs: Set<UUID>?                                                    = nil) {
        self.identity                                                                    = identity
        self.electromagneticSpectrumCoverage                                             = electromagneticSpectrumCoverage
        self.observatoryType                                                             = observatoryType
        self.location                                                                    = location
        self.configurationIDs                                                            = configurationIDs
        self.deviceIDs                                                                   = deviceIDs
    }
}


//MARK: - Type extensions -

public extension PolisObservatory {
    enum CodingKeys: String, CodingKey {
        case identity
        case electromagneticSpectrumCoverage = "electromagnetic_spectrum_coverage"
        case observatoryType                 = "observatory_type"
        case location
        case configurationIDs                = "configuration_ids"
        case deviceIDs                       = "device_ids"
    }
}

extension PolisObservatory: Equatable {
    public static func == (lhs: PolisObservatory, rhs: PolisObservatory) -> Bool {
        lhs.id == rhs.id
    }
}
