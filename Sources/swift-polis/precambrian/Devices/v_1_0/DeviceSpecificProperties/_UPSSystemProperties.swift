//
//  UPSSystemProperties.swift
//  
//
//  Created by Georg Tuparev on 23.06.23.
//

import Foundation

public struct UPSSystemProperties: Codable {
    public enum OperatingMode: String, Codable {
        case safeShutdownOnly   = "safe_shutdown_only"
        case microgridOperation = "microgrid_operation"
        case unknown
    }

    public enum RechargeSupplyOption: String, Codable {
        case upstreamPowerGrid      = "upstream_power_grid"
        case fuelPoweredGenerator   = "fuelPowered_generator"
        case photovoltaicsGenerator = "photovoltaics_generator"
    }

    public var modeOfOperation: OperatingMode
    public var guaranteeOperationDuration: PolisMeasurement?
    public var rechargeSupplyOption: [RechargeSupplyOption]?

    //TODO: Implement public initialiser!
}
