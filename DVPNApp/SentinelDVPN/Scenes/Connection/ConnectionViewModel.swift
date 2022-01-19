import Combine
import SentinelWallet
import SwiftUI
import FlagKit
import GRPC

final class ConnectionViewModel: ObservableObject {
//    typealias Router = AnyRouter<Route>
//    private let router: Router
    
    @Published private(set) var bandwidthConsumedGB: String?
    
    @Published private var downloadSpeed: String?
    @Published private var downloadSpeedUnits: String?
    @Published private var uploadSpeed: String?
    @Published private var uploadSpeedUnits: String?
    
    @Published private var initialBandwidthGB: String?
    @Published private var duration: String? {
        didSet {
            connectionInfoViewModels[3] = .init(type: .duration, value: duration ?? "-s", symbols: "")
        }
    }
    
    // Location Selector
    @Published private(set) var countryImage: ImageAsset.Image?
    @Published private(set) var countryName: String?
    @Published private(set) var moniker: String?
    @Published private(set) var speedImage: ImageAsset.Image?
    
    // Connection Status
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    @Published private(set) var connectionInfoViewModels: [ConnectionInfoViewModel] = []

    @Published var isLoading: Bool = false

    enum Route {
        case error(Error)
        case warning(Error)
//        case openPlans(for: DVPNNodeInfo, delegate: PlansViewModelDelegate?)
        case accountInfo
        case dismiss(isEnabled: Bool)
        case resubscribe(completion: (Bool) -> Void)
    }
    
    private let model: ConnectionModel
    private var cancellables = Set<AnyCancellable>()
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    
    init(model: ConnectionModel) {
        self.model = model
        
        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .updateConnection(status):
                    self?.updateConnection(status: status)
                    log.info("Status was changed to \(status)")
                case let .update(isTunnelActive):
                    self?.updateConnection(isConnected: isTunnelActive)
                case let .updateLocation(countryName, moniker):
                    self?.updateLocation(countryName: countryName, moniker: moniker)
                case let .updateBandwidth(bandwidth):
                    self?.updateBandwidth(bandwidth: bandwidth)
                case let .updateTimer(initialDate):
                    self?.startDurationTracking(initialDate: initialDate)
                case let .updateSubscription(initialBandwidth, bandwidthConsumed):
                    self?.updateSubscription(
                        initialBandwidth: initialBandwidth,
                        bandwidthConsumed: bandwidthConsumed
                    )
                case let .setButton(isLoading):
                    self?.updateButton(isLoading: isLoading)
                    #warning("TODO")
//                    self?.router.play(event: .dismiss(isEnabled: !isLoading))
                case let .error(error):
                    self?.show(error: error)
                case let .openPlans(node):
                    #warning("TODO")
//                    router.play(event: .openPlans(for: node, delegate: self))
                case let .warning(error):
                    #warning("TODO")
//                    router.play(event: .warning(error))
                case let .resubscribe(node):
                    #warning("TODO")
//                    router.play(
//                        event: .resubscribe { [weak self] result in
//                            guard let self = self, result else {
//                                return
//                            }
//
//                            router.play(event: .openPlans(for: node, delegate: self))
//                        }
//                    )
                }
            }
            .store(in: &cancellables)
        
        setConnectionInfoViewModels()
        model.setInitNodeInfo()
    }
    
    deinit {
        timer?.upstream.connect().cancel()
    }
    
    func viewWillAppear() {
        model.checkNodeForUpdate()
    }
}

extension ConnectionViewModel {
    var gridViewModels: [GridViewModelType] {
        connectionInfoViewModels.map { GridViewModelType.connectionInfo($0) }
    }
    
    func toggleConnection(_ newState: Bool) {
        newState ? model.connect() : model.disconnect()
    }

    func didEnterForeground() {
        model.refreshNodeState()
    }

    @objc
    func didTapAccountInfoButton() {
//        router.play(event: .accountInfo)
    }
}

// MARK: - PlansViewModelDelegate

#warning("TODO")
//extension ConnectionViewModel: PlansViewModelDelegate {
//    func openConnection() {
//        model.checkNodeForUpdate()
//    }
//}

// MARK: - Private

extension ConnectionViewModel {
    private func show(error: Error) {
//        router.play(event: .error(error))
    }
    
    private func setConnectionInfoViewModels() {
        connectionInfoViewModels = [
            .init(type: .download, value: downloadSpeed ?? "-", symbols: downloadSpeedUnits ?? "KB/s"),
            .init(type: .upload, value: uploadSpeed ?? "-", symbols: uploadSpeedUnits ?? "KB/s"),
            .init(type: .bandwidth, value: initialBandwidthGB ?? "-", symbols: L10n.Common.gb),
            .init(type: .duration, value: duration ?? "-s", symbols: "")
        ]
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
           let image = Flag(countryCode: countryCode)?.originalImage {
            self.countryImage = image
        }
    }
    
    private func updateBandwidth(bandwidth: Bandwidth) {
        (downloadSpeed, downloadSpeedUnits) = bandwidth.download.getBandwidthKBorMB
        (uploadSpeed, uploadSpeedUnits) = bandwidth.upload.getBandwidthKBorMB
        speedImage = bandwidth.speedImage
        setConnectionInfoViewModels()
    }

    private func updateButton(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func updateSubscription(initialBandwidth: String, bandwidthConsumed: String) {
        self.initialBandwidthGB = (Int64(initialBandwidth) ?? 0).bandwidthGBString
        self.bandwidthConsumedGB = (Int64(bandwidthConsumed) ?? 0).bandwidthGBString
        setConnectionInfoViewModels()
    }
    
    func startDurationTracking(initialDate: Date?) {
        guard let initialDate = initialDate else {
            timer?.upstream.connect().cancel()
            duration = nil
            return
        }
        
        timer?.upstream.connect().cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
        
        timer?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let timeToShow = -Int64(initialDate.timeIntervalSinceNow)
                self.duration = timeToShow.secondsAsString()
            }
            .store(in: &cancellables)
    }
}
