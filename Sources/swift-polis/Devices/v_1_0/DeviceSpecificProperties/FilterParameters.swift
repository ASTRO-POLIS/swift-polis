//
//  FilterParameters.swift
//  
//
//  Created by Georg Tuparev on 24.06.23.
//

import Foundation

public struct FilterParameters: Codable {

    public enum FilterType: String, Codable {
        case clear
        case neutralDensity = "neutral_density"
        case blue, green, red
        case u, b, v, r, i, h, j, k, l, m, n

        case johnsonU       = "johnson_u"
        case johnsonB       = "johnson_b"
        case johnsonV       = "johnson_v"
        case johnsonR       = "johnson_r"
        case johnsonI       = "johnson_i"
        case johnsonJ       = "johnson_j"
        case johnsonH       = "johnson_h"
        case johnsonK       = "johnson_k"
        case johnsonL       = "johnson_l"
        case johnsonM       = "johnson_m"
        case johnsonN       = "johnson_n"

        case besselU        = "bessel_u"
        case besselB        = "bessel_b"
        case besselV        = "bessel_v"
        case besselR        = "bessel_r"
        case besselI        = "bessel_i"

        case cousinsR       = "cousins_r"
        case cousinsI       = "cousins_i"

        case sloanU         = "sloan_u"
        case sloanG         = "sloan_g"
        case sloanR         = "sloan_r"
        case sloanI         = "sloan_i"
        case sloanZ         = "sloan_z"

        case stromgrenU     = "stromgren_u"
        case stromgrenB     = "stromgren_b"
        case stromgrenBeta  = "stromgren_beta"
        case stromgrenY     = "stromgren_y"

        case gunnG          = "gunn_g"
        case gunnR          = "gunn_r"
        case gunnI          = "gunn_i"
        case gunnZ          = "gunn_z"

        case narrowband

        case hAlpha         = "h_alpha"
        case hBeta          = "h_beta"

        case forbiddenOI    = "forbidden_oi"
        case forbiddenOII   = "forbidden_oii"
        case forbiddenOIII  = "forbidden_oiii"
        case forbiddenNII   = "forbidden_nii"
        case forbiddenSII   = "forbidden_sii"

        case other
    }

    public var type = FilterType.other       //TODO: Originally this was `name: String`, but I replace it with enum that I borrowed from RTML and filter providers. OK?
    public var diameter: PolisMeasurement    // [mm]
    public var waveLength: PolisMeasurement? // [m]
    public var transmissionCurve: URL?       // Points to external site
}

