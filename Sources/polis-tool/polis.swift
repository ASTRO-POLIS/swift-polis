//
//  polis.swift
//  swift-polis
//
//  Created by Georg Tuparev on 29.11.25.
//

import Foundation

    let helpPrompt = """
NAME
   polis

SYNOPSIS
   polis -l path_to_local_polis_root  -r url_to_remote_polis_provider [-t | --test]
   polis -h | --help

DESCRIPTION
   Validates the content of the input directory and prepares configuration files and templates for all other eMandate tools

ARGUMENTS
   -c path_to_config_file           -- The path to the local copy of the POLIS provider static data [required]
   -r url_to_remote_polis_provider  -- The fURL to the remote POLIS provider used for syncing [required]
   -t | --test                      -- Executes the utility in test mode. Can use build-in configuration. Could be used ONLY while debugging! [optional]
   -h | --help                      -- Prints this help

EXIT STATUS
   The polis utility exits 0 on success, and > 0 if an error occurs
   99   -- unknown error
"""

@main
struct PolisTool {


    static func main() async throws {
        print(helpPrompt)
    }
}
