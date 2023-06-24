//
//  BeamSplitterProperties.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct BeamSplitterProperties: Codable {

    public var transmissionPercentage: Double  //TODO: Originally suggested type is Int, but is it not better to have Double (0.0 ... 1.0)?
    public var reflectionPercentage: Double    //TODO: Originally suggested type is Int, but is it not better to have Double (0.0 ... 1.0)?
    public var material: String?               //TODO: Why not Enum?
}
