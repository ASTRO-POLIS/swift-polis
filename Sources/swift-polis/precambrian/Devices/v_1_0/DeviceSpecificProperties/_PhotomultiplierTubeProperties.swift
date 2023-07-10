//
//  PhotomultiplierTubeProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct PhotomultiplierTubeProperties: Codable {

    public var numberOfPixelsX: Int?
    public var numberOfPixelsY: Int?
    public var pixelSizeX: PolisPropertyValue?                // [µ]
    public var pixelSizeY: PolisPropertyValue?                // [µ]

}
