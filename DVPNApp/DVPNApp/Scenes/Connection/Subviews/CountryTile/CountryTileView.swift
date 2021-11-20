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
            Image(uiImage: viewModel.icon)
                .resizable()
                .frame(width: 50, height: 41)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.title ?? "")
                    .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
                
                Text(viewModel.subtitle)
                    .applyTextStyle(.grayPoppins(ofSize: 10, weight: .medium))
            }
            
            Spacer()
            
            Image(uiImage: viewModel.speedImage ?? UIImage())
                .frame(width: 20, height: viewHeight)
        }
    }
    
    var emptyCountry: some View {
        HStack(alignment: .center) {
            Text(L10n.Connection.LocationSelector.fetching)
                .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
            
            Spacer()
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

// swiftlint:enable force_unwrapping
