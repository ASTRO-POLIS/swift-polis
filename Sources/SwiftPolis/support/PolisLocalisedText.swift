//
//  PolisLocalisedText.swift
//  swift-polis
//
//  Created by Hasmik Mirzakhanyan on 20.03.26.
//

import Foundation

/// Usage pattern
///
/// **The goal:** To make human readable / meaningful Strings (e.g. names, descriptions, ...) localisable and accessed
/// easily and updatable by clients
///
/// **Steps:**
/// 1. Setup the localisation environment globally
/// ```swift
/// let plp = PolisLocalisationPreferences.shared
/// plp.setPreferredLanguages(["en", "de", "de-at", "am", "bg"])
/// ```
///
/// 2. In Rep-type classes, to extract the proper string:
/// 2.1. During the initialisation:
/// ```swift
/// var name = PolisLocalisedText(polisObject.name)
/// ```
/// 2.2. Extract the proper String
/// ```swift
/// let string = name.resolved
/// ```
///
/// 3. Set new values and prepare them to be persistent:
/// ```swift
/// var name = PolisLocalisedText(polisObject.name)
/// name["bg"] = "Рожен"
/// polisObject = name.rawValues
/// ```


/// Singleton responsible for language-code normalisation and preference resolution.
public final class PolisLocalisationPreferences: @unchecked Sendable {
    
    /// Shared singleton instance.
    public static let shared = PolisLocalisationPreferences()

    /// Preferred base language codes currently used for resolution.
    ///
    /// By default this is derived from the current process locale. It can be
    /// overridden with ``setPreferredLanguages(_:)`` (useful for CLI tools).
    public var preferredLanguages: [String] {
        _lock.lock()
        defer { _lock.unlock() }
        return _overriddenPreferredLanguages ?? _systemPreferredLanguages
    }

    //MARK: Private APIs
    private init() {
        self._systemPreferredLanguages = Self.computePreferredBaseLanguageCodes()
    }

    /// Overrides preferred languages used for text resolution.
    ///
    /// The provided codes are normalised to base language codes, de-duplicated,
    /// and guaranteed to include `"en"` as a fallback.
    ///
    /// - Parameter languageCodes: Preferred language codes in priority order.
    public func setPreferredLanguages(_ languageCodes: [String]) {
        let normalised = Self.normalisePreferredLanguageCodes(languageCodes)
        _lock.lock()
        _overriddenPreferredLanguages = normalised
        _lock.unlock()
    }

    /// Clears runtime overrides and falls back to system preferred languages.
    public func resetPreferredLanguagesOverride() {
        _lock.lock()
        _overriddenPreferredLanguages = nil
        _lock.unlock()
    }

    /// Returns the device preferred language list normalised to base language codes.
    ///
    /// The resulting array is de-duplicated and always includes `"en"` as a final
    /// fallback language if it is not already present.
    fileprivate func preferredBaseLanguageCodes() -> [String] { preferredLanguages }

    /// Normalises any language code (e.g. `en-US`, `en_US`) to base form (`en`).
    fileprivate func normalisedBaseLanguageCode(_ code: String) -> String {
        code
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .first
            .map { String($0).lowercased() } ?? code.lowercased()
    }

    private static func computePreferredBaseLanguageCodes() -> [String] {
        normalisePreferredLanguageCodes(Locale.preferredLanguages)
    }

    private static func normalisePreferredLanguageCodes(_ languageCodes: [String]) -> [String] {
        var seen             = Set<String>()
        var result: [String] = []

        for language in languageCodes {
            let normalised = language
                .replacingOccurrences(of: "_", with: "-")
                .split(separator: "-")
                .first
                .map { String($0).lowercased() } ?? language.lowercased()

            if seen.insert(normalised).inserted { result.append(normalised) }
        }

        if seen.insert("en").inserted { result.append("en") }

        return result
    }

    private let _lock = NSLock()
    private let _systemPreferredLanguages: [String]
    private var _overriddenPreferredLanguages: [String]?
}

/// Localised text storage keyed by normalised base language code.
///
/// Keys are normalised via ``PolisLocalisationPreferences/normalisedBaseLanguageCode(_:)`` (for example,
/// `"en-US"` and `"en_US"` are stored as `"en"`). Use ``resolved`` to get the
/// best match for current user language preferences.
///
/// **Examples**
/// ```swift
/// var title = PolisLocalisedText([
///     "en": "Observatory",
///     "bg-BG": "Обсерватория"
/// ])
///
/// // Reads with language normalisation:
/// let english = title["en-US"]   // "Observatory"
///
/// // Writes with language normalisation:
/// title["fr-FR"] = "Observatoire"
///
/// // Value resolved against preferred device languages:
/// let displayTitle = title.resolved
/// ```
public struct PolisLocalisedText: Sendable {

    /// Creates localised text from a dictionary of language-code/value pairs.
    ///
    /// - Parameter values: Dictionary where keys are language codes (e.g. `"en"`,
    ///   `"bg-BG"`). Keys are normalised to base language codes during storage.
    ///
    /// Example:
    /// ```swift
    /// let text = PolisLocalisedText([
    ///     "en-US": "Telescope",
    ///     "de-DE": "Teleskop"
    /// ])
    ///
    /// text.rawValues
    /// // ["en": "Telescope", "de": "Teleskop"]
    /// ```
    public init(_ values: LocalisableString? = [:]) {
        let valueDictionary = values != nil ? values! : [:]
        self.storage = Dictionary(
            uniqueKeysWithValues: valueDictionary.map { key, value in
                (PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(key), value)
            }
        )
    }

    /// Creates localised text with a single language entry.
    ///
    /// - Parameters:
    ///   - text: Localised text value.
    ///   - languageCode: Language code for the provided text. The code is
    ///     normalised to a base language code before storage.
    ///
    /// Example:
    /// ```swift
    /// let text = PolisLocalisedText(text: "Observatory", languageCode: "en-GB")
    /// print(text.rawValues) // ["en": "Observatory"]
    /// ```
    public init(text: String, languageCode: String) {
        self.storage = [PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(languageCode): text]
    }

    /// The underlying language-code/value dictionary.
    ///
    /// Language keys are returned in their normalised base form.
    public var rawValues: LocalisableString { storage }

    /// Reads or updates the value for the given language code.
    ///
    /// The provided language code is normalised before lookup or assignment.
    /// Setting `nil` removes the value for the normalised key.
    public subscript(_ code: String) -> String? {
        get { storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(code)] }
        set { storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(code)] = newValue }
    }

    /// Sets localised text for a specific language code.
    ///
    /// - Parameters:
    ///   - text: Text to store.
    ///   - languageCode: Language code whose base language key will be updated.
    public mutating func set(_ text: String, for languageCode: String) {
        storage[PolisLocalisationPreferences.shared.normalisedBaseLanguageCode(languageCode)] = text
    }

    /// Resolves the best localised value for current user preferences.
    ///
    /// Resolution order:
    /// 1. Preferred languages from ``PolisLocalisationPreferences/preferredBaseLanguageCodes()``.
    /// 2. English (`"en"`), if available.
    /// 3. Any first available value in storage.
    /// 4. Empty string when storage is empty.
    ///
    /// Example:
    /// ```swift
    /// let text = PolisLocalisedText(["en": "Sky", "es": "Cielo"])
    /// let valueForUI = text.resolved
    /// ```
    public var resolved: String { resolve() ?? "" }

    //MARK: Private APIs
    private var storage: [String: String]

    private func resolve() -> String? {
        for preferred in PolisLocalisationPreferences.shared.preferredBaseLanguageCodes() {
            if let value = storage[preferred] {
                return value
            }
        }

        return storage["en"] ?? storage.values.first
    }
}
