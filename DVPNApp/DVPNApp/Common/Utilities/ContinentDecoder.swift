//
//  ContinentDecoder.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.10.2021.
//

import Foundation
import SentinelWallet

// MARK: - ContinentDecoder

final class ContinentDecoder {
    static let shared = ContinentDecoder()
    
    private var countryCodeToContinent: [String: String] = [:]
    
    init() {
        let countriesExtraURL = Bundle.main.url(forResource: "co.sentinel.sentinellite.regional.countries_extras", withExtension: "json")!
        let countriesExtraData = try! Data(contentsOf: countriesExtraURL, options: [])
        let countriesExtra = try! JSONDecoder().decode([CountryExtra].self, from: countriesExtraData)
        
        for countryExtra in countriesExtra {
            countryCodeToContinent[countryExtra.alpha2.uppercased()] = countryExtra.continent
        }
    }
    
    func isInContinent(node: Node, continent: Continent) -> Bool {
        let countryCode = countryCodeToContinent[
            CountryFormatter.code(for: node.info.location.country) ?? ""
        ]
        
        return countryCode == continent.rawValue
    }
}

// MARK: - CountryExtra

struct CountryExtra: Codable {
    let alpha2: String
    let capital: String?
    let area: String?
    let population: String?
    let continent: String
}
