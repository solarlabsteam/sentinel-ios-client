//
//  OnboardingView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 11.08.2021.
//

import Foundation
import SwiftUI
import UIKit
import FlagKit

struct OnboardingView: View {

    @ObservedObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var mainButton: some View {
        Button(action: viewModel.didTapCreateButton) {
            HStack {
                Spacer()
                Text(L10n.Onboarding.Button.start.uppercased())
                    .applyTextStyle(.mainButton)

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(25)
    }

    var importView: some View {
        HStack(spacing: 2) {
            Text(L10n.Onboarding.Button.ImportNow.text)
                .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))

            Button(action: viewModel.didTapImportButton) {
                Text(L10n.Onboarding.Button.ImportNow.action)
                    .applyTextStyle(.navyBluePoppins(ofSize: 12, weight: .semibold))
                    .underline()
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(viewModel.step.imageName)

            Text(viewModel.step.title)
                .applyTextStyle(.whitePoppins(ofSize: 25, weight: .bold))
                .padding()

            Text(viewModel.step.description)
                .applyTextStyle(.whitePoppins(ofSize: 15))
                .multilineTextAlignment(.center)
                .padding(.horizontal)


            Spacer()

            mainButton
                .padding()
            importView
                .padding()
        }
        .padding(.vertical)
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getOnboardingScene()
    }
}
