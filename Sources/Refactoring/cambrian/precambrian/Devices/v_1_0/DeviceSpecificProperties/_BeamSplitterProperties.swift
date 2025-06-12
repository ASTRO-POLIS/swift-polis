//
//  BeamSplitterProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct BeamSplitterProperties: Codable {

    public var transmissionPercentage: Double?  // [%]
    public var reflectionPercentage: Double?    // [%]
    public var material: String?               //TODO: Why not Enum? -> There are way too many possible materials for us to provide a huge list, better just to keep it as a string
}
