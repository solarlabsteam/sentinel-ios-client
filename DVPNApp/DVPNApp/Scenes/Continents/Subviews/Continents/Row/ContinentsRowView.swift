//
//  ContinentsRowView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsRowView: View {
    private let type: Continent
    @Binding var count: Int
    private let action: () -> Void

    init(type: Continent, count: Binding<Int>, action: @escaping () -> Void) {
        self.type = type
        self._count = count
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    type.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .center) {
                        Text(type.title)
                            .applyTextStyle(.whiteMain(ofSize: 14, weight: .medium))
                        Text(L10n.Continents.availableNodes(count))
                            .applyTextStyle(.grayMain(ofSize: 11))
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.all, 15)
            .background(Asset.Colors.purple.color.asColor)
            .cornerRadius(5)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContinentsRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContinentsRowView(type: .AS, count: .constant(60), action: {})
    }
}
