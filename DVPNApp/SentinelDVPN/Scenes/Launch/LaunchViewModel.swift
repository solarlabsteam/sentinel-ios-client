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
        
        context.nodesService.loadAllNodes { [weak self] result in
            if case let .success(nodes) = result {
                self?.context.nodesService.loadNodesInfo(for: nodes)
            }
        }
        
        loadData()
    }
}

extension LaunchViewModel {
    func loadData() {
        context.preloadService.loadData { [weak self] in
            self?.context.nodesService.loadAllNodes { [weak self] result in
                if case let .success(nodes) = result {
                    self?.context.nodesService.loadNodesInfo(for: nodes, completion: {
                        DispatchQueue.main.async {
                            self?.delegate?.dataLoaded()
                        }
                    })
                }
            }
        }
    }
}
