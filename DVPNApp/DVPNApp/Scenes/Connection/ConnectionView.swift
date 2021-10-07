import SwiftUI
import Combine

struct ConnectionView: View {
    
    @ObservedObject private var viewModel: ConnectionViewModel
    @State private var backgroundXFactor = 1
    
    private let navyColor = Asset.Colors.Redesign.navyBlue.color
    
    init(viewModel: ConnectionViewModel) {
        self.viewModel = viewModel
    }
    
    var locationSelector: some View {
        CountryTileView(
            viewModel:
                    .init(
                        id: "0",
                        icon: viewModel.countryImage ?? UIImage(),
                        title: viewModel.countryName,
                        subtitle: viewModel.moniker ?? "",
                        speed: viewModel.speedImage ?? UIImage()
                    )
        )
            .padding(.horizontal, 16)
    }
    
    var bandwidthConsumedView: some View {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                Text(viewModel.bandwidthConsumedGB ?? "0")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("GB")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Asset.Colors.Redesign.lightGray.color.asColor)
            }
            .frame(width: 160, height: 160)
            .overlay(
                RoundedRectangle(cornerRadius: 80)
                    .stroke(viewModel.isConnected ?
                                navyColor.asColor : navyColor.withAlphaComponent(0.2).asColor, lineWidth: 8)
            )
            .padding(.bottom, 10)
            
            Text(L10n.Connection.Info.dataUser)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Asset.Colors.Redesign.textGray.color.asColor)
        }
    }
    
    var connectionInfoMainView: some View {
        // TODO: @tori move to VM
        GridView(models: [
            .connectionInfo(.init(type: .download, value: viewModel.downloadSpeed ?? "", symbols: viewModel.downloadSpeedUnits)),
            .connectionInfo(.init(type: .upload, value: viewModel.uploadSpeed ?? "", symbols: viewModel.uploadSpeedUnits)),
            .connectionInfo(.init(type: .bandwidth, value: viewModel.initialBandwidthGB ?? "", symbols: "GB")),
            .connectionInfo(.init(type: .duration, value: viewModel.duration ?? "-", symbols: ""))
        ])
    }
    
    var connectionStatus: some View {
        Text(viewModel.connectionStatus.title)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Asset.Colors.Redesign.textGray.color.asColor)
    }

    var body: some View {
        GeometryReader { gProxy in
            VStack {
                VStack(spacing: 0) {
                    locationSelector
                        .padding(.horizontal, 10)
                    
                    bandwidthConsumedView
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                    
                    connectionInfoMainView
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Asset.Colors.Redesign.lightBlue.color.asColor, lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Toggle(
                            "",
                            isOn: .init(get: { return viewModel.isConnected }, set: viewModel.toggleConnection(_:))
                        )
                        .labelsHidden()
                        .toggleStyle(ConnectionToggleStyle(isLoading: $viewModel.isLoading))
                        .disabled(viewModel.isLoading)
                        .padding(.bottom, 10)
                        
                        connectionStatus
                    }
                }
                .padding(.bottom, 44)
                .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
            }
            .onAppear { viewModel.viewWillAppear() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.didEnterForeground()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getConnectionScene()
    }
}
