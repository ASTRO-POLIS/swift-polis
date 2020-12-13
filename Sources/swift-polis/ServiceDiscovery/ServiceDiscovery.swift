//
//  ServiceDiscovery.swift
//
//
//  Created by Georg Tuparev on 18/11/2020.
//

/// This file defines types related to the POLIS provider discovery. The exact process is described in different documents.
/// Later versions might implement a reference implementation of the discovery process, but every provider is free to
/// implement its own procedures.
///
/// **Note for Swift developers:** Before releasing version 1.0 of this package all types will implement `Codable` to
/// allow easy marshalling first from JSON and later from XML data.

import Foundation

/// POLIS APIs are either in XML or in JSON format. For reasons stated elsewhere in the documentation XML APIs are
/// preferred for production code. In contrast, JSON is often easier to be used for new development (no need of schema
/// implementation) and often easier to be used from mobile and web applications. But because its fragility it should be
/// avoided in stable production systems.
/// **Note:** Perhaps later we might need also `plist` format?
public enum PolisDataFormat: String, Codable, CaseIterable {
    case xml
    case json
}


/// `PolisProviderType` defines different types of POLIS providers.
///
/// Only `public` provider should be used in production. Public providers should run on server with enough bandwidth and
/// computational power capable of accommodating multiple parallel client requests every second. Only when a `public`
/// server is unreachable, its `mirror` (if available) should be accessed until the main server is down.
/// `private` provider's main purpose is to act as a local cache for larger institutions and should be not accessed from
/// outside. They might require user authentication.
/// `experimental` providers are sandboxes for new developments, and might require authentication.
public enum PolisProviderType: Codable, CustomStringConvertible {
    case `public`         // default
    case `private`
    case mirror(String)   // The uid of the service provider being mirrored.
    case experimental

    public init(from decoder: Decoder) throws {
        if let value = try? String(from: decoder) {
            if      value == "public"           { self  = .`public` }
            else if value == "private"          { self  = .`private` }
            else if value == "experimental"     { self  = .experimental }
            else if value.hasPrefix("mirror::") {
                let components = value.components(separatedBy: "::")

                if components.count == 2 { self  = .mirror(components[1]) }
                else {
                    let context = DecodingError.Context( codingPath: decoder.codingPath, debugDescription: "Badly formatted mirror option")
                    throw DecodingError.dataCorrupted(context)
                }
            }
            else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing proper decoding format!")
                throw DecodingError.dataCorrupted(context)
            }
        }
        else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode \(String.self)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
            case .`public`:           try container.encode(String("public"))
            case .`private`:          try container.encode(String("private"))
            case .`experimental`:     try container.encode(String("experimental"))
            case .mirror(let siteID): try container.encode(String("mirror::\(siteID))"))
        }
    }

    public var description: String {
        switch self {
            case .`public`:           return "public"
            case .`private`:          return "private"
            case .`experimental`:     return "experimental"
            case .mirror(let siteID): return "mirror(\(siteID)))"
        }
    }
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


/// A list of known
public struct PolisDirectory: Codable, CustomStringConvertible {
    public let lastUpdate: Date
    public var entries: [PolisDirectoryEntry]

    public var description: String {
        var result = "{\n   \"lastUpdate\": \"\(lastUpdate)\",\n"
        result +=    "    \"entries\": [\n"
        for entry in entries {
            result += "      \(entry),\n"
        }
        result += "   ]\n}\n"

        //TODO: Test me for good formatting!
        return result
    }
}

/// All the information needed to identify a site as a POLIS provider
public struct PolisDirectoryEntry: Codable, CustomStringConvertible {
    public let uid: String      // Globally unique ID (UUID version 4)
    public let name: String     // Should be unique to avoid errors, but not a requirement
    public let domain: String   // Fully qualified, e.g. https://polis.observer
    public let providerDescription: String?
    // contact: PolisCommunicationContact
    public let lastUpdate: Date
    public let supportedProtocolLevels: [UInt8]
    public let supportedAPIVersions: [String]
    public let supportedDataTypes: [PolisDataFormat]
    public let providerType: PolisProviderType


    public var description: String {
        var result = " { \"uid\": \"\(uid)}\", "
        result +=    "\"name\": \"\(name)\", "
        result +=    "\"domain\": \"\(domain)\", "
        result +=    "\"providerDescription\": \"\(providerDescription ?? "No description")\", "
        result +=    "\"lastUpdate\": \"\(lastUpdate)\", "
        result +=    "\"supportedProtocolLevels\": \"\(supportedProtocolLevels)\", "
        result +=    "\"supportedAPIVersions\": \"\(supportedAPIVersions)\", "
        result +=    "\"supportedDataTypes\": \"\(supportedDataTypes)\", "
        result +=    "\"providerType\": \"\(providerType)\" }"

        //TODO: Test me for good formatting!
        return result
    }
}

//MARK: - CustomStringConvertible extensions -
extension PolisDataFormat: CustomStringConvertible {
    public var description: String {
        switch self {
            case .xml:  return "\"xml\""
            case .json: return "\"json\""
        }
    }
}
