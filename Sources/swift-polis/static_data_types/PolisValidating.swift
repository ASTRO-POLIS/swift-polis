//
//  PolisValidating.swift
//
//
//  Created by Georg Tuparev on 23.08.24.
//

import Foundation

// Here we defined types so support validation of POLIS types. It is recommended that all POLIS static types adopt
// the `PolisValidating` protocol.

/// Basic POLIS data validation
///
/// Each POLIS static type should conform to the `PolisValidating` protocol. The validation should be performed each time when data are read either from
/// a local cache or from a remote POLIS provider. Editors of POLIS static data should also validate data before saving the data to a persistent store (local or remote).
public protocol PolisValidating {
    func allProperties() -> [String]
    func requiredProperties() -> [String]

    func validateFor(property: String, value: String) -> (result: Bool, validationErrors: [PolisValidatorHelper.PolisValidationErrors]?)
}

public class PolisValidatorHelper {

    public enum PolisValidationErrors: Error {
        case requiredProperty
        case nonEmptyProperty
    }

    static var shared = PolisValidatorHelper()

}

extension PolisValidating {
    public func allProperties() -> [String] { [] }

    public func requiredProperties() -> [String] { [] }

    func validateFor(property: String, value: String) -> (result: Bool, validationErrors: [PolisValidatorHelper.PolisValidationErrors]?) { (true, nil) }
}
