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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(viewModel.subtitle)
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(uiImage: viewModel.speedImage)
                .frame(width: 20, height: viewHeight)
        }
    }
    
    var emptyCountry: some View {
        HStack(alignment: .center) {
            Text(L10n.Connection.LocationSelector.select)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(uiImage: Asset.Connection.Wifi.scales1.image)
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
