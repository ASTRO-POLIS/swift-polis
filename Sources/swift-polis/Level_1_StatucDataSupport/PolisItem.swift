//
//  PolisItem.swift
//  
//
//  Created by Georg Tuparev on 09/01/2022.
//

import Foundation

//MARK: - Item Ownership -
public enum PolisOwnershipType: String, Codable {
    case university
    case research
    case commercial
    case school
    case network
    case government
    case ngo
    case club
    case consortium
    case cooperative
    case `private`     // personal, amateur, ...
    case other
}

public struct PolisItemOwner: Codable {
    public let name: String?
    public let type: PolisOwnershipType
    public let url: URL?
    public let shortDescription: String?
}

public protocol PolisItem: Identifiable, Codable {
    var id: UUID                         { get }   // Should be `attributes`'s `id`
    var attributes: PolisItemAttributes  { get set }
    var manufacturer: PolisManufacturer? { get set }
    var owners: [PolisItemOwner]?        { get set }
    var imageLinks: [URL]?               { get set }
}

//MARK: - Type Extensions -

// This extension is needed for supporting a well formatted JSON API
public extension PolisItemOwner {
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case url
        case shortDescription = "short_description"
    }
}

//public extension PolisItem {
//    enum CodingKeys: String, CodingKey {
//        case id
//        case attributes
//        case manufacturer
//        case owners
//        case imageLinks = "image_links"
//    }
//}
