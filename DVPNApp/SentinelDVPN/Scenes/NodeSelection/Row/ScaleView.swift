//
//  ScaleView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

private struct Constants {
    let scales = [1, 2, 3, 4, 5]
}
private let constants = Constants()

enum ScaleViewType: Hashable {
    case price(Int)
    case peers(Int)
    case latency(Int)

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

    var scale: Int {
        switch self {
        case let .price(value):
            if value <= 1000 {
                return 1
            }
            if value <= 10_000 {
                return 2
            }
            if value <= 100_000 {
                return 3
            }
            if value <= 1_000_000 {
                return 4
            }
            return 5
            
        case let .peers(value):
            if value <= 10 {
                return 1
            }
            if value <= 25 {
                return 2
            }
            if value <= 50 {
                return 3
            }
            if value <= 100 {
                return 4
            }
            return 5
            
        case let .latency(value):
            if value <= 100 {
                return 1
            }
            if value <= 200 {
                return 2
            }
            if value <= 500 {
                return 3
            }
            if value <= 1000 {
                return 4
            }
            return 5
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
                            .foregroundColor(value <= type.scale ? .white.opacity(Double(value + 1)) : .clear)
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
