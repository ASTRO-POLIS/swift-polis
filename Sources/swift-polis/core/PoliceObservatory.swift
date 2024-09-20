//
//  PoliceObservatory.swift
//  swift-polis
//
//  Created by Georg Tuparev on 20.09.24.
//

/// `ModeOfOperation` ....
public enum PolisModeOfOperation: String, Codable {
    case manual
    case manualWithAutomatedDetector              = "manual_with_automated_detector"
    case manualWithAutomatedDetectorAndScheduling = "manual_with_automated_detector_and_scheduling"
    case autonomous
    case remote
    case robotic
    case mixed                                       // e.g. in case of Network
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
}


//TODO: Observatory should have:
//public var modeOfOperation: ModeOfOperation?

