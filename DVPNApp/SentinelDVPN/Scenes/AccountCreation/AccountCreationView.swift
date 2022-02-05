//
//  AccountCreationView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import Foundation
import SwiftUI
import AlertToast

struct AccountCreationView: View {
    
    @ObservedObject private var viewModel: AccountCreationViewModel
    @State private var showAlert = true
    
    init(viewModel: AccountCreationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 30) {
            leftColumn
            rightColumn
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Colors.accentColor.color.asColor)
        .toast(isPresenting: $viewModel.alertContent.isShown) {
            viewModel.alertContent.toast
        }
    }
}

extension AccountCreationView {
    private var leftColumn: some View {
        VStack(spacing: 10)  {
            mnemonicFields

            Button(action: viewModel.didTapMnemonicActionButton) {
                Text(
                    viewModel.mode == .restore ?
                    L10n.AccountCreation.Import.Button.paste : L10n.AccountCreation.Create.Button.copy)
                    .applyTextStyle(.whitePoppins(ofSize: 12))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .border(Asset.Colors.navyBlue.color.asColor, width: 1)
                    .cornerRadius(2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 10)  {
            if viewModel.address != nil {
                walletAddress
            }

            if viewModel.mode == .create {
                HStack {
                    Text(L10n.AccountCreation.warning)
                        .applyTextStyle(.textBody)
                        .padding(.all, 10)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .border(Asset.Colors.borderGray.color.asColor, width: 1)
                .cornerRadius(2)

                termsView
                    .padding()

                mainButton
                    .padding(.horizontal)

                importView
                    .padding()
            } else {
                mainButton
                    .padding(.horizontal)
            }
        }
    }

    private var walletAddress: some View {
        Button(action: viewModel.didTapCopyAddress) {
            ZStack(alignment: .leading) {
                Text(viewModel.address ?? "")
                    .applyTextStyle(.whitePoppins(ofSize: 11, weight: .medium))
                    .padding(.bottom, 10)
                    .padding([.horizontal, .top], 8)
                    .border(Asset.Colors.borderGray.color.asColor, width: 1)
                    .cornerRadius(2)
                    .padding(.top, 20)
                
                HStack {
                    Spacer().frame(width: 10, height: 10)
                    Text(L10n.AccountCreation.walletAddress)
                        .applyTextStyle(.textBody)
                        .padding(.horizontal, 5)
                        .background(Asset.Colors.accentColor.color.asColor)
                        .padding(.bottom, 12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var mnemonicFields: some View {
        VStack {
            ForEach(Array(viewModel.mnemonic.indices).chunked(into: 4), id: \.self) { range in
                MnemonicLineView(range: range, mnemonic: $viewModel.mnemonic, isEnabled: $viewModel.isEnabled)
            }
        }
    }

    private var mainButton: some View {
        Button(action: viewModel.didTapMainButton) {
            HStack {
                Spacer()
                Text(viewModel.mode.buttonTitle.uppercased())
                    .applyTextStyle(.mainButton)

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(25)
        .buttonStyle(PlainButtonStyle())
    }

    private var termsView: some View {
        HStack(spacing: 2) {
            Button(action: viewModel.didCheckTerms) {
                if viewModel.isTermsChecked {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(Asset.Colors.navyBlue.color.asColor)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(Asset.Colors.borderGray.color.asColor)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack(alignment: .top, spacing: 5) {
                Text(L10n.AccountCreation.Terms.text)
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))
                
                Link(destination: UserConstants.privacyURL) {
                    Text(L10n.AccountCreation.Terms.button)
                        .applyTextStyle(.whitePoppins(ofSize: 12, weight: .semibold))
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()
        }
    }

    private var importView: some View {
        HStack(spacing: 2) {
            Text(L10n.AccountCreation.Button.ImportNow.text)
                .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))

            Button(action: viewModel.didTapChangeMode) {
                Text(L10n.AccountCreation.Button.ImportNow.action)
                    .applyTextStyle(.navyBluePoppins(ofSize: 12, weight: .semibold))
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct AccountCreationView_Previews_Restore: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.makeAccountCreationScene(with: .restore)
            .frame(minWidth: 1000, minHeight: 500)
    }
}

struct AccountCreationView_Previews_Create: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.makeAccountCreationScene(with: .create)
            .frame(minWidth: 1000, minHeight: 500)
    }
}
