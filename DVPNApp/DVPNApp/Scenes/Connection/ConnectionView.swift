import SwiftUI
import Combine

struct ConnectionView: View {
    
    @ObservedObject private var viewModel: ConnectionViewModel
    
    private let navyColor = Asset.Colors.navyBlue.color
    
    init(viewModel: ConnectionViewModel) {
        self.viewModel = viewModel
    }
    
    var locationSelector: some View {
        HStack {
            CountryTileView(
                viewModel:
                        .init(
                            id: "0",
                            icon: viewModel.countryImage ?? UIImage(),
                            title: viewModel.countryName,
                            subtitle: viewModel.moniker ?? "",
                            speed: nil
                        )
            ).padding(.horizontal, 16)
            
            
            ConnectionInfoView(
                viewModel: .init(
                    type: .duration,
                    value: viewModel.duration ?? "-s",
                    symbols: ""
                )
            )
        }
    }
    
    var bandwidthView: some View {
        HStack(spacing: 0) {
            ConnectionInfoView(
                viewModel: .init(
                    type: .bandwidth,
                    value: viewModel.initialBandwidthGB ?? "-",
                    symbols: L10n.Common.gb
                )
            )
            
            Image(uiImage: Asset.Icons.bandwidth.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
                .foregroundColor(.white)
                .padding()
            
            ConnectionInfoView(
                viewModel: .init(
                    type: .consumed,
                    value: viewModel.bandwidthConsumedGB ?? "-",
                    symbols: L10n.Common.gb
                )
            )
        }
    }
    
    var speedView: some View {
        HStack(spacing: 0) {
            ConnectionInfoView(
                viewModel: .init(
                    type: .download,
                    value: viewModel.downloadSpeed ?? "-",
                    symbols: viewModel.downloadSpeedUnits ?? "KB/s"
                )
            )
            
            Spacer()
            
            ConnectionInfoView(
                viewModel: .init(
                    type: .upload,
                    value: viewModel.uploadSpeed ?? "-",
                    symbols: viewModel.uploadSpeedUnits ?? "KB/s"
                )
            )
        }
    }
    
    var connectionStatus: some View {
        Text(viewModel.connectionStatus.title.uppercased())
            .applyTextStyle(.whiteMain(ofSize: 22, weight: .bold))
    }
    
    var connectionButton: some View {
        Button(action: viewModel.toggleConnection) {
            ZStack(alignment: .leading) {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                        .frame(width: 15, height: 15)
                        .padding(.leading, 30)
                }
                
                HStack {
                    Text(!viewModel.isConnected ? L10n.Connection.Button.connect : L10n.Connection.Button.disconnect)
                        .applyTextStyle(.whiteMain(ofSize: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .disabled(viewModel.isLoading)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(5)
    }

    var body: some View {
        GeometryReader { gProxy in
            VStack {
                VStack(spacing: 0) {
                    
                    Image(uiImage: Asset.Connection.power.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .padding(.all, 60)
                    
                    VStack {
                    
                    bandwidthView
                        .padding(.top, 20)
                    
                    connectionStatus
                        .padding(.top, 10)
                        
                        locationSelector
                        Spacer()
                        speedView
                        connectionButton
                    }.padding()
                }
                .padding(.bottom, 44)
                .background(Asset.Colors.accentColor.color.asColor)
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
