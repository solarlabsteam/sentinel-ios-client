//
//  OnboardingView.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 10.11.2021.
//

import Foundation
import SwiftUI
import FlagKit

struct OnboardingView: View {

    @ObservedObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var nextButton: some View {
        Button(action: viewModel.didTapNextButton) {
            Image(systemName: "arrow.forward")
                .resizable()
                .frame(width: 20, height: 15)
                .padding()
                .background(Asset.Colors.dirtyBlue.color.asColor)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
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
        .buttonStyle(PlainButtonStyle())
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
            .buttonStyle(PlainButtonStyle())
        }
    }

    var tabView: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()

            viewModel.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            VStack(spacing: 0) {
                Text(viewModel.title)
                    .applyTextStyle(.title)
                    .padding()

                Text(viewModel.description)
                    .applyTextStyle(.descriptionText)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Spacer()
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                tabView
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height * 2 / 3
                    )

                if viewModel.isLastPage {
                    mainButton
                        .padding()
                    importView
                        .padding()
                } else {
                    HStack {
                        Spacer()
                        nextButton
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
            .background(Asset.Colors.accentColor.color.asColor)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.makeOnboardingScene()
            .frame(minWidth: 1000, minHeight: 500)
    }
}
