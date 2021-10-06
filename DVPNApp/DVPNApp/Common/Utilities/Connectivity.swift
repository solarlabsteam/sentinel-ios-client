//
//  Connectivity.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 26.08.2021.
//

import Foundation
import Alamofire

final class Connectivity {
    class func isConnectedToInternet() -> Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }
}
