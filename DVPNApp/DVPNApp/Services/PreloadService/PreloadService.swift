//
//  PreloadService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import Combine

final class PreloadService {
    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }
}

extension PreloadService: PreloadServiceType {
    func loadData() -> Future<Void, Error> {
        userService.loadBalance()
    }
}
