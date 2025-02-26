//
//  PlansView.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI

struct PlansView: View {
    
    @ObservedObject private var viewModel: PlansViewModel

    init(viewModel: PlansViewModel) {
        self.viewModel = viewModel
    }
    
    var bandwidthView: some View {
        VStack(spacing: 0) {
            Text("\(viewModel.gbToBuy)")
                .applyTextStyle(.whitePoppins(ofSize: 44, weight: .bold))
            
            Text(L10n.Common.gb)
                .applyTextStyle(.lightGrayPoppins(ofSize: 18, weight: .regular))
        }
        .frame(width: 140, height: 140)
        .overlay(
            RoundedRectangle(cornerRadius: 70)
                .stroke(Asset.Colors.navyBlue.color.asColor, lineWidth: 6)
        )
    }
    
    var mainButton: some View {
        Button(action: viewModel.didTapSubscribe) {
            ZStack(alignment: .leading) {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                        .frame(width: 15, height: 15)
                }
                HStack {
                    Spacer()
                    
                    Text(L10n.Plans.subscribe)
                        .applyTextStyle(.mainButton)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(25)
        .disabled(viewModel.isLoading)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Button(action: viewModel.didTapCrossButton) {
                Image(systemName: "multiply")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }

            VStack(spacing: 0) {
                VStack {
                    Text(L10n.Plans.title)
                        .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()

                    bandwidthView
                }
                .padding()

                VStack {
                    CounterView(
                        text: $viewModel.prettyTokesToSpend,
                        togglePlus: viewModel.togglePlus,
                        toggleMinus: viewModel.toggleMinus
                    )

                    mainButton
                        .padding()
                }
                .padding()
            }
            .background(Asset.Colors.accentColor.color.asColor)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.Colors.lightBlue.color.asColor, lineWidth: 1)
            )
            .padding(.all, 28)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.accentColor.color.asColor.opacity(0.85))
        .edgesIgnoringSafeArea(.bottom)
    }
}
