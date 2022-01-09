//
//  PolisConfiguration.swift
//  
//
//  Created by Georg Tuparev on 16/09/2021.
//

import Foundation
import SoftwareEtudes

//public func jsonString(from: [PolisSupportedAPIVersion]) -> String? {
//    let jsonEncoder = JSONEncoder()
//
//    guard let data = try? jsonEncoder.encode(from) else { return nil }
//
//    return  String(data: data, encoding: .utf8)
//    //TODO: Test this method!
//}
//
//public func validate(polisSupportedAPIVersions: [PolisSupportedAPIVersion]) -> Bool {
//    //FIXME: Do we really need this function?
//    for apiVersion in polisSupportedAPIVersions {
//        for (api, versions) in apiVersion {
//            if !polisSupportedAPIs.contains(api) { return false }
//            for frameworkVersion in frameworkSupportedAPIVersions() {
//                for (frameworkAPI, frameworkVersions) in frameworkVersion {
//                    if (frameworkAPI == api) {
//                        for fV in frameworkVersions {
//                            if versions.contains(fV) { return true }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    //TODO: Test this method!
//
//    return false
//}
