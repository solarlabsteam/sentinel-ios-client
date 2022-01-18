//
//  PreloadService.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import Combine

final class PreloadService {
    private let userService: UserService
    
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserService) {
        self.userService = userService
    }
}

extension PreloadService: PreloadServiceType {
    func loadData(completion: @escaping () -> Void) {
        userService.loadBalance()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in
                    completion()
                },
                receiveValue: { _ in }
            ).store(in: &cancellables)
    }
}
