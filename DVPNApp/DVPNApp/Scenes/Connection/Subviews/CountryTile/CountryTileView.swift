import SwiftUI
import FlagKit

struct CountryTileView: View {
    private var viewModel: CountryTileViewModel
    
    private let viewHeight: CGFloat = 66
    
    init(
        viewModel: CountryTileViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var countryViewFlag: some View {
        HStack(alignment: .center) {
            viewModel.icon.asImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 41)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.title ?? "")
                    .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
                
                Text(viewModel.subtitle)
                    .applyTextStyle(.grayPoppins(ofSize: 10, weight: .medium))
            }
            
            Spacer()
            
            viewModel.speedImage.asImage
                .frame(width: 20, height: viewHeight)
        }
    }
    
    var emptyCountry: some View {
        HStack(alignment: .center) {
            Text(L10n.Connection.LocationSelector.fetching)
                .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
            
            Spacer()
            
            Asset.Connection.Wifi.scales1.image.asImage
                .frame(width: 20, height: viewHeight)
        }
    }
    
    @ViewBuilder
    var body: some View {
        if viewModel.title != nil {
            countryViewFlag
        } else {
            emptyCountry
        }
    }
}

// swiftlint:disable force_unwrapping
#if os(iOS)
struct CountryTileView_Previews: PreviewProvider {
    static var previews: some View {
        CountryTileView(
            viewModel:
                    .init(
                        id: "id",
                        icon: Flag(countryCode: "EE")!.image(style: .roundedRect),
                        title: "Test",
                        subtitle: "8.8.8.8",
                        speed: Asset.Connection.Wifi.scales3.image
                    )
        )
    }
}

#elseif os(macOS)
struct CountryTileView_Previews: PreviewProvider {
    static var previews: some View {
        CountryTileView(
            viewModel:
                    .init(
                        id: "id",
                        icon: Flag(countryCode: "EE")!.originalImage,
                        title: "Test",
                        subtitle: "8.8.8.8",
                        speed: Asset.Connection.Wifi.scales3.image
                    )
        )
    }
}

#endif
