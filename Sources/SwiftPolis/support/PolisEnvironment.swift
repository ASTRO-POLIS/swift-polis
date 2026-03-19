//
//  PolisEnvironment.swift
//  swift-polis
//
//  Created by Zhanna Hakobyan on 13.12.25.
//

public struct PolisEnvironment: Sendable {
    nonisolated(unsafe) private static var _shared: PolisEnvironment?

    @MainActor
    public static func configure(_ environment: PolisEnvironment) {
        precondition(_shared == nil, "PolisEnvironment.configure(_:) called more than once")
        _shared = environment
    }

    nonisolated(unsafe)
    public static var shared: PolisEnvironment {
        guard let environment = _shared
        else { fatalError("PolisEnvironment.configure(_:) must be called before first use") }

        return environment
    }

    public let polisFileResourceFinder  : PolisFileResourceFinder
    public let polisRemoteResourceFinder: PolisRemoteResourceFinder
    // public let synchronisationProvider: RemoteSynchronisationProviding?
}
