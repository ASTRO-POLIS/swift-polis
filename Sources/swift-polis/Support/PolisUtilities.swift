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


/// A String extension that is used only in swift-polis (as far as we know)
extension String {
    /// Adds `@` prefix if already does not exist
    public func mustStartWithAtSign() -> String { self.hasPrefix("@") ? self : "@\(self)" }
}

/// This is for internal use only! Without this the URL returned by the utility functions for some strange reason has no
/// URL schema!
func normalisedPath(_ path: String) -> String {
    if path.hasSuffix("/") { return path }
    else                   { return "\(path)/" }
}
