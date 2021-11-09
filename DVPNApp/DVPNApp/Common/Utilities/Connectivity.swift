//
//  Connectivity.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 26.08.2021.
//

import Foundation
import Alamofire

enum Connectivity {
    func isConnectedToInternet() -> Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }
}
