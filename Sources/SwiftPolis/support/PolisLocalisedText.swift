//
//  PolisLocalisedText.swift
//  swift-polis
//
//  Created by Hasmik Mirzakhanyan on 20.03.26.
//

import Foundation

/// Singleton responsible for language-code normalization and preference resolution.
public final class PolisLocalisationPreferences: Sendable {
    /// Shared singleton instance.
    public static let shared = PolisLocalisationPreferences()

    /// Cached preferred base language codes for the current process.
    public let preferredLanguages: [String]

    private init() {
        self.preferredLanguages = Self.computePreferredBaseLanguageCodes()
    }

    /// Returns the device preferred language list normalised to base language codes.
    ///
    /// The resulting array is de-duplicated and always includes `"en"` as a final
    /// fallback language if it is not already present.
    fileprivate func preferredBaseLanguageCodes() -> [String] {
        preferredLanguages
    }

    /// Normalises any language code (e.g. `en-US`, `en_US`) to base form (`en`).
    fileprivate func normalisedBaseLanguageCode(_ code: String) -> String {
        code
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .first
            .map { String($0).lowercased() } ?? code.lowercased()
    }

    private static func computePreferredBaseLanguageCodes() -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for language in Locale.preferredLanguages {
            let normalised = language
                .replacingOccurrences(of: "_", with: "-")
                .split(separator: "-")
                .first
                .map { String($0).lowercased() } ?? language.lowercased()
            if seen.insert(normalised).inserted {
                result.append(normalised)
            }
        }

        if seen.insert("en").inserted {
            result.append("en")
        }

        return result
    }
}

/// Localized text storage keyed by normalised base language code.
///
/// Keys are normalised via ``PolisLocalisationPreferences/normalisedBaseLanguageCode(_:)`` (for example,
/// `"en-US"` and `"en_US"` are stored as `"en"`). Use ``resolved`` to get the
/// best match for current user language preferences.
public struct PolisLocalisedText {
    private var storage: [String: String]

    /// Creates localized text from a dictionary of language-code/value pairs.
    ///
    /// - Parameter values: Dictionary where keys are language codes (e.g. `"en"`,
    ///   `"bg-BG"`). Keys are normalised to base language codes during storage.
    public init(_ values: [String: String] = [:]) {
        self.storage = Dictionary(
            uniqueKeysWithValues: values.map { key, value in
                (PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(key), value)
            }
        )
    }

    /// Creates localized text with a single language entry.
    ///
    /// - Parameters:
    ///   - text: Localized text value.
    ///   - languageCode: Language code for the provided text. The code is
    ///     normalised to a base language code before storage.
    public init(text: String, languageCode: String) {
        self.storage = [PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(languageCode): text]
    }

    /// The underlying language-code/value dictionary.
    ///
    /// Language keys are returned in their normalised base form.
    public var rawValues: [String: String] { storage }

    /// Reads or updates the value for the given language code.
    ///
    /// The provided language code is normalised before lookup or assignment.
    /// Setting `nil` removes the value for the normalised key.
    public subscript(_ code: String) -> String? {
        get { storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(code)] }
        set { storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(code)] = newValue }
    }

    /// Sets localized text for a specific language code.
    ///
    /// - Parameters:
    ///   - text: Text to store.
    ///   - languageCode: Language code whose base language key will be updated.
    public mutating func set(_ text: String, for languageCode: String) {
        storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(languageCode)] = text
    }

    private func resolve() -> String? {
        for preferred in PolisLocalisationPreferences.shared.preferredBaseLanguageCodes() {
            if let value = storage[preferred] {
                return value
            }
        }

        return storage["en"] ?? storage.values.first
    }

    /// Resolves the best localized value for current user preferences.
    ///
    /// Resolution order:
    /// 1. Preferred languages from ``PolisLocalisationPreferences/preferredBaseLanguageCodes()``.
    /// 2. English (`"en"`), if available.
    /// 3. Any first available value in storage.
    /// 4. Empty string when storage is empty.
    public var resolved: String { resolve() ?? "" }
}
