import Foundation
import Combine
import SentinelWallet
import SwiftUI
import FlagKit
import GRPC

final class HomeViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router
    
    @Published private(set) var bandwidthConsumedGB: String?
    
    @Published private(set) var downloadSpeed: String?
    @Published private(set) var downloadSpeedUnits: String?
    
    @Published private(set) var uploadSpeed: String?
    @Published private(set) var uploadSpeedUnits: String?
    
    @Published private(set) var initialBandwidthGB: String?
    @Published private(set) var duration: String?
    
    // Location Selector
    @Published private(set) var countryImage: UIImage?
    @Published private(set) var countryName: String?
    @Published private(set) var moniker: String?
    @Published private(set) var speedImage: UIImage?
    
    // Connection Status
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    @Published var isLoading: Bool = false

    enum Route {
        case error(Error)
        case warning(Error)
        case subscribe(node: DVPNNodeInfo)
        case openPlans(for: DVPNNodeInfo)
        case settings
    }
    
    private let model: HomeModel
    private var cancellables = Set<AnyCancellable>()
    
    private var skipViewWillAppear = true
    
    init(model: HomeModel, router: Router) {
        self.model = model
        self.router = router
        
        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .updateConnection(status):
                    self?.updateConnection(status: status)
                    log.info("Status was changed to \(status)")
                case let .update(isTunelActive):
                    self?.updateConnection(isConnected: isTunelActive)
                case let .updateLocation(countryName, moniker):
                    self?.updateLocation(countryName: countryName, moniker: moniker)
                case let .updateBandwidth(bandwidth):
                    self?.updateBandwidth(bandwidth: bandwidth)
                case let .updateSubscription(initialBandwidth, bandwidthConsumed):
                    self?.updateSubscription(
                        initialBandwidth: initialBandwidth,
                        bandwidthConsumed: bandwidthConsumed
                    )
                case let .setButton(isLoading):
                    self?.updateButton(isLoading: isLoading)
                case let .error(error):
                    self?.show(error: error)
                case let .openPlans(node):
                    router.play(event: .openPlans(for: node))
                case let .warning(error):
                    router.play(event: .warning(error))
                case .openNodes:
                    #warning("TODO handle node selection")
                }
                
            }
            .store(in: &cancellables)
    }
    
    func toggleConnection(_ newState: Bool) {
        UIImpactFeedbackGenerator.lightFeedback()
        newState ? model.connect() : model.disconnect()
    }

    func viewWillAppear() {
        model.checkNodeForUpdate()
    }

    func didEnterForeground() {
        model.refreshNodeState()
    }

    @objc
    func didTapSettingsButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .settings)
    }
}

// MARK: - Private

extension HomeViewModel {
    private func show(error: Error) {
        router.play(event: .error(error))
    }

    private func updateConnection(isConnected: Bool) {
        self.isConnected = isConnected
    }

    private func updateConnection(status: ConnectionStatus) {
        self.connectionStatus = status
        self.isLoading = isLoading || status.isLoading
    }
    
    private func updateLocation(countryName: String, moniker: String) {
        self.countryName = countryName
        self.moniker = moniker
        if let countryCode = CountryFormatter.code(for: countryName),
           let image = Flag(countryCode: countryCode)?.image(style: .roundedRect) {
            self.countryImage = image
        }
    }
    
    private func updateBandwidth(bandwidth: Bandwidth) {
        (downloadSpeed, downloadSpeedUnits) = bandwidth.download.getBandwidthKBorMB
        (uploadSpeed, uploadSpeedUnits) = bandwidth.upload.getBandwidthKBorMB
        speedImage = bandwidth.speedImage
    }

    private func updateButton(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func updateSubscription(initialBandwidth: String, bandwidthConsumed: String) {
        self.initialBandwidthGB = (Int64(initialBandwidth) ?? 0).bandwidthGBString
        self.bandwidthConsumedGB = (Int64(bandwidthConsumed) ?? 0).bandwidthGBString
    }
}
