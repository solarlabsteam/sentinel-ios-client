//
//  PurchasesView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import SwiftUI
import UIKit
import FlagKit

struct PurchasesView: View {

    @ObservedObject private var viewModel: PurchasesViewModel

    init(viewModel: PurchasesViewModel) {
        self.viewModel = viewModel
    }

    var buyButton: some View {
        Button(action: viewModel.didTapBuy) {
            ZStack(alignment: .leading) {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                        .frame(width: 15, height: 15)
                        .padding()
                }
                HStack {
                    Text(L10n.Purchases.Button.buy.capitalized)
                        .applyTextStyle(.whiteMain(ofSize: 20, weight: .bold))
                        .padding(.vertical, 25)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .disabled(viewModel.isLoading)
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(5)
    }
    
    var termsView: some View {
        HStack(alignment: .top, spacing: 5) {
            Text(L10n.Purchases.Terms.title)
                .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))
            
            Button(action: viewModel.didTapTerms) {
                Text(L10n.Purchases.Terms.button)
                    .applyTextStyle(.whiteMain(ofSize: 10, weight: .semibold))
            }
        }
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(zip(viewModel.options.chunked(into: 2).indices, viewModel.options.chunked(into: 2))), id: \.0) { index, models in
                    HStack(spacing: 15) {
                        ForEach(models, id: \.self) { model in
                            PurchaseOptionView(
                                model: model,
                                action: { viewModel.togglePurchase(vm: model)
                                }
                            )
                        }
                    }
                }
            }
            .padding()
            
            termsView

            buyButton
                .padding()

            Text(L10n.Purchases.description(viewModel.selectedOption?.price ?? "?"))
                .applyTextStyle(.lightGrayMain(ofSize: 10, weight: .light))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            Spacer()
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct PurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getPurchasesScene()
    }
}
