//
//  ContinentsRowViewType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

enum Continent: String {
    case AF
    case SA
    case NA
    case OC
    case AS
    case EU
    case AN
}

extension Continent {
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
        case .AF: return Image(uiImage: Asset.Continents.africa.image)
        case .SA: return Image(uiImage: Asset.Continents.southAmerica.image)
        case .NA: return Image(uiImage: Asset.Continents.northAmerica.image)
        case .OC: return Image(uiImage: Asset.Continents.oceania.image)
        case .AS: return Image(uiImage: Asset.Continents.asia.image)
        case .EU: return Image(uiImage: Asset.Continents.europe.image)
        case .AN: return Image(uiImage: Asset.Continents.antarctica.image)
        }
    }
}
