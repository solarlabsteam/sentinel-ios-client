//
//  PreloadServiceType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import Combine

protocol PreloadServiceType {
    func loadData() -> Future<Void, Error>
}
