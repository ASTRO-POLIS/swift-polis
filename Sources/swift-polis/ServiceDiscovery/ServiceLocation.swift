//
//  ServiceLocation.swift
//  
//
//  Created by Georg Tuparev on 20/11/2020.
//

import Foundation

/// Definition of well known paths and APIs
public struct PolisPredefinedServicePaths {
    public static let defaultDomainName = "polis.observer"
    public static let xmlDataFormat     = "xml"
    public static let jsonDataFormat    = "json"

    // Level 1 resource paths
    public static let rootServiceDirectory  = "polis"
    public static let polisServiceDirectory = "service_directory"
}

/// Must be subclassed depending on the needs for synchronous or asynchronous communication with the provider,
/// data caching, update frequency etc.
public class AbstractPolisProvider {
    public var domainName: String
    public var dataFormat: PolisDataFormat
    public var apiVersion: String

    //TODO: Use Georg's SemanticVersion.swift (SoftwareEtudes repo) to validate the apiVersion
    public init?(domainName: String = PolisPredefinedServicePaths.defaultDomainName,
         dataFormat: String = PolisPredefinedServicePaths.xmlDataFormat,
         apiVersion: String = "*") {
        var dataFormatToBeUsed: String

        if (dataFormat != PolisPredefinedServicePaths.xmlDataFormat) && (dataFormat != PolisPredefinedServicePaths.jsonDataFormat) {
            dataFormatToBeUsed = PolisPredefinedServicePaths.xmlDataFormat
        } else {
            dataFormatToBeUsed = dataFormat
        }

        self.domainName = dataFormatToBeUsed
        self.dataFormat = dataFormat == "xml" ? PolisDataFormat.xml : PolisDataFormat.json
        self.apiVersion = apiVersion
    }

    // These methods should be overridden
    public func isAccessible() -> Bool { false }
    public func isPolisService() -> Bool { false }
    public func providerType() -> PolisProvider? { nil }
    public func siteDirectoryEntry() -> PolisDirectoryEntry? { nil }
    
}

/// Use these JSONDecoder and JSONEncoder to convert types to and from JSON
@available(OSX 10.12, *)
public class PolisJSONDecoder: JSONDecoder {

    let dateFormatter = ISO8601DateFormatter()

    override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date       = self.dateFormatter.date(from: dateString)

            if let date = date { return date }
            else {
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "Date values must be ISO8601 formatted")
            }
        }
    }
}

@available(OSX 10.12, *)
public class PolisJSONEncoder: JSONEncoder {
    override init() {
        super.init()

        dateEncodingStrategy = .iso8601
    }
}
