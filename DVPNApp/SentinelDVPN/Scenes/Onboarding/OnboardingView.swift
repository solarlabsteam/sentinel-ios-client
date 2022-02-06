//
//  OnboardingView.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 10.11.2021.
//

import Foundation
import SwiftUI

struct OnboardingView: View {

    @ObservedObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                tabView
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height / 2
                    )
                    .padding(.top)

                Spacer()

                if viewModel.isLastPage {
                    mainButton
                    importView
                        .padding()
                } else {
                    HStack {
                        Spacer()
                        nextButton
                            .padding()
                    }
                }
            }
            .padding(.vertical)
            .background(Asset.Colors.accentColor.color.asColor)
        }
    }
}

extension OnboardingView {
    private var nextButton: some View {
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
            Text(L10n.Onboarding.Button.start.uppercased())
                .applyTextStyle(.textBody)
                .padding()
                .background(Asset.Colors.dirtyBlue.color.asColor)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var importView: some View {
        VStack(spacing: 2) {
            Text(L10n.Onboarding.Button.ImportNow.text)
                .applyTextStyle(.lightGrayPoppins(ofSize: 8, weight: .light))

            Button(action: viewModel.didTapImportButton) {
                Text(L10n.Onboarding.Button.ImportNow.action)
                    .applyTextStyle(.navyBluePoppins(ofSize: 8, weight: .semibold))
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var tabView: some View {
        HStack(alignment: .center, spacing: 50) {
            viewModel.image
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.title)
                    .applyTextStyle(.title)
                    .multilineTextAlignment(.leading)

                Text(viewModel.description)
                    .applyTextStyle(.descriptionText)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 10) {
                    ForEach(0...2, id: \.self) { tag in
                        Image(systemName: "circle.fill")
                            .resizable()
                            .tag(tag)
                            .frame(width: 7, height: 7)
                            .foregroundColor(
                                Asset.Colors.navyBlue.color
                                    .withAlphaComponent(tag == viewModel.currentPage ? 1 : 0.1)
                                    .asColor
                            )
                    }
                }
            }
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.makeOnboardingScene()
            .frame(minWidth: 1000, minHeight: 500)
    }
}
