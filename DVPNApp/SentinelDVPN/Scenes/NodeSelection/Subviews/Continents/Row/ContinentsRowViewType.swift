//
//  Continent.swift
//  SOLARdVPN
//
//  Created by Lika Vorobeva on 29.11.2021.
//

import Foundation
import SwiftUI

enum Continent: String, CaseIterable {
    case africa = "AF"
    case southAmerica = "SA"
    case northAmerica = "NA"
    case asia = "AS"
    case europe = "EU"
    case other
}

extension Continent {
    static var allContinents: [Continent] {
        var continents = Continent.allCases
        continents.removeLast()
        return continents
    }
}

extension Continent {
    var title: String {
        switch self {
        case .africa: return L10n.Continents.Title.africa
        case .southAmerica: return L10n.Continents.Title.southAmerica
        case .northAmerica: return L10n.Continents.Title.northAmerica
        case .asia: return L10n.Continents.Title.asia
        case .europe: return L10n.Continents.Title.europe
        case .other: return L10n.Continents.Title.other
        }
    }

    var index: Int {
        switch self {
        case .africa: return 2
        case .southAmerica: return 4
        case .northAmerica: return 3
        case .asia: return 1
        case .europe: return 0
        case .other: return 5
        }
    }

    var image: Image {
        switch self {
        case .africa: return Asset.Continents.africa.image.asImage
        case .southAmerica: return Asset.Continents.southAmerica.image.asImage
        case .northAmerica: return Asset.Continents.northAmerica.image.asImage
        case .asia: return Asset.Continents.asia.image.asImage
        case .europe: return Asset.Continents.europe.image.asImage
        case .other: return Image(systemName: "ellipsis")
        }
    }
}
