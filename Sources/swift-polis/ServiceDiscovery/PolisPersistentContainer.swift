//
//  PolisPersistentContainer.swift
//  
//
//  Created by Georg Tuparev on 09/07/2021.
//

import Foundation


public class PolisPersistentContainer {

    public var rootPath: URL

    public init?(rootPath: URL, shouldCreate: Bool = false) {
        self.rootPath = rootPath
    }

    public func isRootPathAccessible() -> Bool {
            //TODO: Implement me!
        fatalError("isRootPathAccessible NOT IMPLEMENTED!")

        return false
    }
    // Managing the state
    private var isLoaded   = false
    private var hasChanges = false

}
