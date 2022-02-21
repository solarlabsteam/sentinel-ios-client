//
//  LaunchViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 16.02.2022.
//

import Foundation

protocol LaunchViewModelDelegate: AnyObject {
    func dataLoaded()
}

final class LaunchViewModel: ObservableObject {
    typealias Context = HasPreloadService & HasNodesService
    
    private let context: Context
    private weak var delegate: LaunchViewModelDelegate?

    init(context: CommonContext, delegate: LaunchViewModelDelegate?) {
        self.context = context
        self.delegate = delegate
        
        loadData()
    }
}

extension LaunchViewModel {
    func loadData() {
        context.preloadService.loadData {
            log.debug("Balance is loaded")
        }
        
       context.nodesService.loadAllNodes { [weak self] result in
            if case let .success(nodes) = result {
                self?.context.nodesService.loadNodesInfo(for: nodes) {}
                
                self?.context.nodesService.loadSubscriptions(completion: { _ in 
                    DispatchQueue.main.async {
                        self?.delegate?.dataLoaded()
                    }
                })
            }
       }
    }
}
