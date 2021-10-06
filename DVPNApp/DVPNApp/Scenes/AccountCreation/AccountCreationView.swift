//
//  AccountCreationView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import Foundation
import SwiftUI

struct AccountCreationView: View {

    @ObservedObject private var viewModel: AccountCreationViewModel

    init(viewModel: AccountCreationViewModel) {
        self.viewModel = viewModel

        UIScrollView.appearance().bounces = false
    }

    var walletAddress: some View {
        ZStack(alignment: .leading) {
            Text(viewModel.address ?? "")
                .font(.system(size: 11, weight: .medium))
                .padding(.bottom, 10)
                .padding([.horizontal, .top], 8)
                .border(Asset.Colors.Redesign.borderGray.color.asColor, width: 1)
                .cornerRadius(2)
                .padding(.top, 20)

            HStack {
                Spacer().frame(width: 10, height: 10)
                Text(L10n.AccountCreation.walletAddress)
                    .padding([.horizontal], 5)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Asset.Colors.Redesign.borderGray.color.asColor)
                    .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
            }
            .padding(.bottom, 12)
        }
    }

    var mnemonicFields: some View {
        VStack {
            ForEach(Array(viewModel.mnemonic.indices).chunked(into: 4), id: \.self) { range in
                MnemonicLineView(range: range, mnemonic: $viewModel.mnemonic, isEnabled: $viewModel.isEnabled)
            }
        }
    }

    var mainButton: some View {
        Button(action: viewModel.didTapMainButton) {
            HStack {
                Spacer()
                Text(viewModel.mode.buttonTitle.uppercased())
                    .foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor)
                    .font(.system(size: 13, weight: .semibold))

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.Redesign.navyBlue.color.asColor)
        .cornerRadius(25)
    }

    var termsView: some View {
        HStack(spacing: 2) {
            Button(action: viewModel.didCheckTerms) {
                if viewModel.isTermsChecked {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(Asset.Colors.Redesign.navyBlue.color.asColor)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(Asset.Colors.Redesign.borderGray.color.asColor)
                }
            }

            Text(L10n.AccountCreation.Terms.text)
                .font(.system(size: 12, weight: .light))

            Button(action: viewModel.didTapTerms) {
                Text(L10n.AccountCreation.Terms.button)
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .medium))
            }

            Spacer()
        }
    }

    var importView: some View {
        HStack(spacing: 2) {
            Text(L10n.AccountCreation.Button.ImportNow.text)
                .font(.system(size: 12, weight: .light))

            Button(action: viewModel.didTapChangeMode) {
                Text(L10n.AccountCreation.Button.ImportNow.action)
                    .foregroundColor(Asset.Colors.Redesign.navyBlue.color.asColor)
                    .font(.system(size: 12, weight: .medium))
                    .underline()
            }
        }
    }

    var body: some View {
        ScrollView {
            if viewModel.mode == .create {
                walletAddress
            }

            mnemonicFields

            if viewModel.mode == .restore {
                HStack {
                    Button(action: viewModel.didTapPaste) {
                        Text(L10n.AccountCreation.Import.Button.paste)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .border(Asset.Colors.Redesign.navyBlue.color.asColor, width: 1)
                            .cornerRadius(2)
                            .padding()
                    }

                    Spacer()
                }


                if viewModel.address != nil {
                    walletAddress
                }
            }

            if viewModel.mode == .create {
                HStack {
                    Spacer()
                    Text(L10n.AccountCreation.warning)
                        .font(.system(size: 10, weight: .regular))
                        .padding(.vertical)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .border(Asset.Colors.Redesign.borderGray.color.asColor, width: 1)
                .cornerRadius(2)
                .padding(.vertical)
            }

            Spacer()

            if viewModel.mode == .create {
                termsView
                    .padding()

                mainButton
                    .padding()

                importView
                    .padding()
            } else {
                mainButton
                    .padding()
                    .padding(.top, 50)
            }
        }
        .padding()
        .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AccountCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountCreationScene(mode: .restore)
    }
}
