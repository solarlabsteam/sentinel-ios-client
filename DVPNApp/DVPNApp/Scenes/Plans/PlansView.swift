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
            
            Text("GB")
                .applyTextStyle(.lightGrayPoppins(ofSize: 18, weight: .regular))
        }
        .frame(width: 140, height: 140)
        .overlay(
            RoundedRectangle(cornerRadius: 70)
                .stroke(Asset.Colors.Redesign.navyBlue.color.asColor, lineWidth: 6)
        )
    }
    
    var mainButton: some View {
        Button(action: viewModel.didTapSubscribe) {
            HStack {
                if viewModel.isLoading {
                    ActivityIndicator(isAnimating: $viewModel.isLoading, style: .medium)
                }
                Spacer()
                
                Text("SUBSCRIBE")
                    .applyTextStyle(.mainButton)
                
                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.Redesign.navyBlue.color.asColor)
        .cornerRadius(25)
        .disabled(viewModel.isLoading)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("How much DVPN you want to spend?")
                        .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 30)
                        .padding(.horizontal)
                    
                    bandwidthView
                        .padding(.bottom, 50)
                }
                .padding()
                
                VStack {
                    CounterView(
                        text: .constant(viewModel.prettyTokesToSpend + " " + L10n.Common.Dvpn.title),
                        togglePlus: viewModel.togglePlus,
                        toggleMinus: viewModel.toggleMinus
                    )
                    
                    mainButton
                        .padding(.all, 30)
                }
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}
