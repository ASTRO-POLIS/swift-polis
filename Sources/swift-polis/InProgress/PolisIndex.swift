//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2022 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//


import Foundation

public class PolisIndexNode {
    var id: UUID

    init(id: UUID) {
        self.id = id
    }
}

public class PolisIndexSite: PolisIndexNode {

    init(id: UUID, parent: PolisIndexSite? = nil, assumedSubSiteIDs: [UUID] = [UUID]()) {
        self.parent            = parent
        self.assumedSubSiteIDs = assumedSubSiteIDs

        super.init(id: id)
    }

    public func idPath() -> String {
        var currentSite: PolisIndexSite? = self
        var pathComponents               = [String]()

        while currentSite != nil {
            pathComponents.insert(currentSite!.id.uuidString, at: 0)
            currentSite = currentSite!.parent
        }

        return pathComponents.joined(separator: "/")
    }

    weak var parent: PolisIndexSite?
    var      assumedSubSiteIDs: [UUID]
    var      subSites                  = [PolisIndexSite]()

    public func indexSiteWith(id: UUID) -> PolisIndexSite? {
        if self.id == id { return self }
        else {
            for aSite in subSites {
                let possibleSite = aSite.indexSiteWith(id: id)

                if possibleSite != nil { return possibleSite }
            }
        }

        return nil
    }
}

public class PolisIndex {

    static var shared = PolisIndex()

    init() { }

    public var sites = [PolisIndexSite]()

    public func indexSiteWith(id: UUID) -> PolisIndexSite? {
        for aSite in sites {
            let possibleSite = aSite.indexSiteWith(id: id)

            if possibleSite != nil { return possibleSite }
        }

        return nil
    }

    @discardableResult public func addSite(id: UUID, assumedSubSiteIDs: [UUID]? = nil) -> PolisIndexSite? {
        let actualSubSiteIDs   = assumedSubSiteIDs != nil ? assumedSubSiteIDs! : [UUID]()
        let newSite            = PolisIndexSite(id: id, assumedSubSiteIDs: actualSubSiteIDs)
        var isNewSiteARootSite = true
        var siteToRemove:  PolisIndexSite?

        for aSite in allSites {
            if aSite.assumedSubSiteIDs.contains(newSite.id) {
                newSite.parent = aSite
                aSite.subSites.append(newSite)
                isNewSiteARootSite = false
                break
            }
            else if newSite.assumedSubSiteIDs.contains(aSite.id) {
                aSite.parent = newSite
                newSite.subSites.append(aSite)
                siteToRemove = aSite
                break
            }
        }

        if siteToRemove != nil {
            for (index, aRootSite) in sites.enumerated() {
                if aRootSite.id == siteToRemove!.id {
                    sites.remove(at: index)
                    break
                }
            }
        }

        if isNewSiteARootSite { sites.append(newSite) }

        allSites.append(newSite)

        return newSite
    }

    private var allSites = [PolisIndexSite]()
}
