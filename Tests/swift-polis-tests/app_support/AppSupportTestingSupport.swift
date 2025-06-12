//===----------------------------------------------------------------------===//
//  AppSupportTestingSupport.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the ASTRO-POLIS open source project
//
// Copyright (c) 2021-2025 Tuparev Technologies and the ASTRO-POLIS project
// authors.
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of ASTRO-POLIS project authors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//
//
//  Created by Georg Tuparev on 09/06/2025.
//

import Foundation
@testable import swift_polis

struct AppSupportTestingSupport {

    static  func objectStore(removeOldData: Bool = false) async throws -> ObjectStore {
        let storeConfig = ObjectStoreConfiguration()

        try storeConfig.setLocalPolisRootFolder("/Users/Shared/Work/polis_tests")

        return  try await storeConfig.objectStore()
    }
}
