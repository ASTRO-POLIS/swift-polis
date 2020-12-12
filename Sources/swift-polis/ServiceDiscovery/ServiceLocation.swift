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

public enum ContactType {
    case twitter(userName: String)
    case whatsApp(phone: String)
    case facebook(id: String)
    case instagram(userName: String)
    case skype(id: String)
}

public struct PolisCommunicationContact {
    public let name: String            // Organisation or user name
    public let email: String           // Required valid email address (will be checked for validity)
    public let additionalContacts: [ContactType]?
}

/// Must be subclassed depending on the needs for synchronous or asynchronous communication with the provider,
/// data caching, update frequency etc.
public class AbstractPolisProvider {
    public var domainName: String
    public var dataFormat: PolisDataFormatType
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
        self.dataFormat = dataFormat == "xml" ? PolisDataFormatType.xml : PolisDataFormatType.json
        self.apiVersion = apiVersion
    }

    // These methods should be overridden
    public func isAccessible() -> Bool { false }
    public func isPolisService() -> Bool { false }
    public func providerType() -> PolisProviderType? { nil }
    public func siteDirectoryEntry() -> PolisDirectoryEntry? { nil }
    
}
