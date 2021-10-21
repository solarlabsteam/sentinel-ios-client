//
//  UserService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import SentinelWallet
import Combine

final class UserService {
    private let walletService: WalletService
    
    let denom = "udvpn"
    
    @Published private(set) var balance: String = "-"

    init(walletService: WalletService) {
        self.walletService = walletService
    }
}

extension UserService {
    func loadBalance() -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.walletService.fetchBalance { result in
                
                switch result {
                case .failure(let error):
                    log.error(error)
                    promise(.failure(error))
      
                case .success(let balances):
                    guard let balance = balances.first(where: { $0.denom == self.denom }) else {
                        self.balance = "0"
                
                        promise(.success(()))
                        
                        return
                    }

                    let prettyBalance = PriceFormatter.fullFormat(amount: balance.amount, denom: "")

                    self.balance = prettyBalance
                    promise(.success(()))
                }
            }
        }
    }
}
