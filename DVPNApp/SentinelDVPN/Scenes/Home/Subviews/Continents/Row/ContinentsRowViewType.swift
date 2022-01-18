//
//  ContinentsRowViewType.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

enum Continent: String, CaseIterable {
    case AF
    case SA
    case NA
    case OC
    case AS
    case EU
    case AN
}

extension Continent {
    // TODO: localize
    var title: String {
        switch self {
        case .AF: return "Africa"
        case .SA: return "South America"
        case .NA: return "North America"
        case .OC: return "Oceania"
        case .AS: return "Asia"
        case .EU: return "Europe"
        case .AN: return "Antarctica"
        }
    }
    
    var image: Image {
        switch self {
        case .AF: return Asset.Continents.africa.image.asImage
        case .SA: return Asset.Continents.southAmerica.image.asImage
        case .NA: return Asset.Continents.northAmerica.image.asImage
        case .OC: return Asset.Continents.oceania.image.asImage
        case .AS: return Asset.Continents.asia.image.asImage
        case .EU: return Asset.Continents.europe.image.asImage
        case .AN: return Asset.Continents.antarctica.image.asImage
        }
    }
    
    var index: Int {
        switch self {
        case .AF: return 5
        case .SA: return 4
        case .NA: return 0
        case .OC: return 3
        case .AS: return 2
        case .EU: return 1
        case .AN: return 6
        }
    }
}
