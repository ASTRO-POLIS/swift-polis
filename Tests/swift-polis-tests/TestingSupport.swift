//===----------------------------------------------------------------------===//
//  TestingSupport.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2023 Tuparev Technologies and the ASTRO-POLIS project
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
import swift_polis

struct TestingSupport {

    static func examplePolisIdentityBAO() -> PolisIdentity {
        PolisIdentity(externalReferences: ["https://bao.am/device?id=1234", "https://bao.am/rtml?dump-1234"],
                      lifecycleStatus:    PolisIdentity.LifecycleStatus.active,
                      lastUpdate:         Date(),
                      name:               "Byurakan Astronomical Observatory",
                      localName:          "ՀՀ ԳԱԱ Վ․Հ․ ՀԱՄԲԱՐՁՈՒՄՅԱՆԻ ԱՆՎԱՆ ԲՅՈՒՐԱԿԱՆԻ ԱՍՏՂԱԴԻՏԱՐԱՆ (ԱԶԳԱՅԻՆ ԱՐԺԵՔ)",
                      abbreviation:       "bao",
                      automationLabel:    "bao_ascom",
                      shortDescription:   "Testing BAO site")
    }
}
