//
//  ScaleView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 07.10.2021.
//

import SwiftUI

private struct Constants {
    let scales = [0, 0.2, 0.4, 0.6, 0.8]
}
private let constants = Constants()

enum ScaleViewType: Hashable {
    case price(Double)
    case peers(Double)
    case latency(Double)

    var title: String {
        switch self {
        case .price:
            return L10n.Home.Node.Details.price
        case .peers:
            return L10n.Home.Node.Details.peers
        case .latency:
            return L10n.Home.Node.Details.latency
        }
    }

    var scale: Double {
        switch self {
        case .price(let value), .peers(let value), .latency(let value):
            return value
        }
    }
}

struct ScaleView: View {
    var type: ScaleViewType

    var body: some View {
        VStack(alignment: .leading) {
            Text(type.title)
                .applyTextStyle(.textBody)
            HStack {
                HStack(spacing: 2) {
                    ForEach(constants.scales, id: \.self) { value in
                        Rectangle()
                            .foregroundColor(value < type.scale ? .white.opacity(value + 0.2) : .clear)
                            .frame(width: 8, height: 6)
                    }
                }
                .cornerRadius(1)
                .padding(.all, 2)
                .border(Color.white.opacity(0.2), width: 0.5)
                .cornerRadius(2)

                Spacer()
            }
        }
    }
}
