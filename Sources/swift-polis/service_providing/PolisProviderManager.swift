//
//  PolisProviderManagerManager.swift
//  swift-polis
//
//  Created by Georg Tuparev on 11.09.24.
//

import Foundation

//TODO: $$$GT Add documentation
public struct PolisProviderConfiguration {

}

public final actor PolisProviderManager {

    public struct StatusChangeNotifications {
        public static let providerWillCreateNotification = Notification.Name("providerWillCreate")
        public static let providerDidCreateNotification = Notification.Name("providerWDidCreate")
    }

    public static var localPolisRootPath: String = "/tmp/"

    public static func createLocalProvider(configuration: PolisProviderConfiguration) throws -> PolisProviderManager {
        return try PolisProviderManager()
    }

    public static func localProvider(using providerUrl: URL) async throws -> PolisProviderManager {
        return try PolisProviderManager()
    }

    public static func mirrorProvider(using providerUrl: URL) async throws -> PolisProviderManager {
        return try PolisProviderManager()
    }

    public static func cachedProvider() async throws -> PolisProviderManager {
        return try PolisProviderManager()
    }

        init() throws {

    }
}

//MARK: - Creation and configuration of the provider -
extension PolisProviderManager {

}
