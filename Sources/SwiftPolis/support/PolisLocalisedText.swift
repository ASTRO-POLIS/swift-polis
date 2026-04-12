//
//  PolisLocalisedText.swift
//  swift-polis
//
//  Created by Hasmik Mirzakhanyan on 20.03.26.
//

import Foundation

//Get device's preferredLanguages and add english as default if it's missing
public func preferredBaseLanguageCodes() -> [String] {
    var seen = Set<String>()
    var result: [String] = []

    for language in Locale.preferredLanguages {
        let normalised = normalisedBaseLanguageCode(language)
        if seen.insert(normalised).inserted {
            result.append(normalised)
        }
    }

    if seen.insert("en").inserted {
        result.append("en")
    }

    return result
}

public func normalisedBaseLanguageCode(_ code: String) -> String {
    code
        .replacingOccurrences(of: "_", with: "-")
        .split(separator: "-")
        .first
        .map { String($0).lowercased() } ?? code.lowercased()
}

public let preferredLanguages: [String] = preferredBaseLanguageCodes()

public struct PolisLocalizedText {
    private var storage: [String: String]

    public init(_ values: [String: String] = [:]) {
        self.storage = Dictionary(
            uniqueKeysWithValues: values.map { key, value in
                (normalisedBaseLanguageCode(key), value)
            }
        )
    }

    public init(text: String, languageCode: String) {
        self.storage = [normalisedBaseLanguageCode(languageCode): text]
    }

    public var rawValues: [String: String] { storage }

    public subscript(_ code: String) -> String? {
        get { storage[normalisedBaseLanguageCode(code)] }
        set { storage[normalisedBaseLanguageCode(code)] = newValue }
    }

    public mutating func set(_ text: String, for languageCode: String) {
        storage[normalisedBaseLanguageCode(languageCode)] = text
    }

    public func resolve() -> String? {
        for preferred in preferredBaseLanguageCodes() {
            if let value = storage[preferred] {
                return value
            }
        }

        return storage["en"] ?? storage.values.first
    }

    public var resolved: String { resolve() ?? "" }
}
