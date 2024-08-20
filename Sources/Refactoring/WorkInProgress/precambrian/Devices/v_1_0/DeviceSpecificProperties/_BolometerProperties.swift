//
//  BolometerProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct BolometerProperties: Codable {

    //TODO: Bolometer has no sensor type? If yes, Bolometer and Camera could be combined with an extra enum for the type of SensingDevice ... Better name? -> Bolometer works differently in the physics to a camera, and hence could have extra user defined properties that do not apply to a camera, hence why I would keep them separate.
    public var numberOfPixelsX: Int?
    public var numberOfPixelsY: Int?
    public var pixelSizeX: PolisPropertyValue?               // [µm]
    public var pixelSizeY: PolisPropertyValue?               // [µm]
    public var material: String?                           //TODO: Why not Enum? Is it optional? -> Optional yes, same as for all material properties, the list is too long for us to be able to summarise it all efficiently
    public var readoutTimeWithoutBinning: PolisPropertyValue // [s]
}
