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

    var skipButton: some View {
        Button(action: viewModel.didTapCreateButton) {
            Text(L10n.Onboarding.Button.skip)
                .applyTextStyle(.secondaryButton)
                .padding(.horizontal)
        }
        .padding()
    }

    var nextButton: some View {
        Button(action: viewModel.didTapNextButton) {
            Text(L10n.Onboarding.Button.next.uppercased())
                .applyTextStyle(.mainButton)
                .padding(.horizontal)
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(25)
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

    var tabView: some View {
        TabView(selection: $viewModel.currentPage,
                content:  {
                    ForEach(viewModel.steps, id: \.self) { model in
                        OnboardingStepView(model: model)
                            .tag(model.tag)
                            .padding()
                    }
                })
            .tabViewStyle(.page(indexDisplayMode: .never))
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

                Spacer()

                PageIndicator(pages: [Int](0...viewModel.steps.count - 1), currentPage: $viewModel.currentPage)

                Spacer()

                if viewModel.isLastPage {
                    mainButton
                        .padding()
                    importView
                        .padding()
                } else {
                    HStack {
                        Spacer()
                        skipButton
                        Spacer()
                        nextButton
                        Spacer()
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
        ModulesFactory.shared.getOnboardingScene()
    }
}
