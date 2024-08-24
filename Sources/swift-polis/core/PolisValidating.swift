//
//  PolisValidating.swift
//
//
//  Created by Georg Tuparev on 23.08.24.
//

import Foundation

public enum PolisValidationErrors: String {
    case requiredProperty = "Property is required"
    case nonEmptyProperty = "Property should not be empty"
}

public protocol PolisValidating {
    var allProperties: [String]      { get }
    var requiredProperties: [String] { get }
    
    func validateFor(property: String, value: String) -> (result: Bool, validationErrors: [PolisValidationErrors]?)
}
