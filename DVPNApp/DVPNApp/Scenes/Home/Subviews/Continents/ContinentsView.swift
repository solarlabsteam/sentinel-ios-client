//
//  ContinentsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    private let continents: [Continent]

    init(
        continents: [Continent]
    ) {
        self.continents = continents
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(continents, id: \.self) { continent in
                ContinentsRowView(type: continent, count: .constant(5), action: {})
                    .padding()
                
                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        ContinentsView(continents: [.AN, .AF, .EU])
    }
}
