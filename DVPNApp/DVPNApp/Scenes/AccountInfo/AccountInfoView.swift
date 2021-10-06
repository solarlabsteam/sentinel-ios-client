//
//  AccountInfoView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import SwiftUI

struct AccountInfoView: View {

    @ObservedObject private var viewModel: AccountInfoViewModel
    
    @Environment(\.openURL) var openURL

    init(viewModel: AccountInfoViewModel) {
        self.viewModel = viewModel
    }

    var addressView: some View {
        HStack(alignment: .center, spacing: 3) {
            Spacer()
            
            Text(viewModel.address)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Asset.Colors.Redesign.lightBlue.color.asColor, lineWidth: 0.5)
        )
    }
    
    // TODO: @tori Move as a separate view and reuse
    
    var shareButton: some View {
        Button {
            viewModel.didTapShare()
        } label: {
            HStack(spacing: 3) {
                Text(L10n.AccountInfo.share)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Asset.Colors.Redesign.navyBlue.color.asColor, lineWidth: 1)
        )
    }
    
    var solarPayButton: some View {
        Button {
            UIImpactFeedbackGenerator.lightFeedback()
            openURL(viewModel.solarPayURL)
        } label: {
            HStack {
                Text(L10n.AccountInfo.topUp)
                    .foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor)
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.Redesign.navyBlue.color.asColor)
        .cornerRadius(25)
    }
    
    var copyButton: some View {
        Button {
            viewModel.didTapCopy()
        } label: {
            HStack(spacing: 3) {
                Text(L10n.AccountInfo.copy)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Asset.Colors.Redesign.navyBlue.color.asColor, lineWidth: 1)
        )
    }

    var qrCode: some View {
        VStack(alignment: .center, spacing: nil) {
            Color(UIColor.white)
                .mask(
                    Image(uiImage: viewModel.qrCode)
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .frame(width: 150, height: 150)
            
            Text(L10n.AccountInfo.qr)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Asset.Colors.lightGray.color.asColor)
        }
    }
    
    var currentPrice: some View {
        HStack {
            Text(L10n.AccountInfo.currentPrice)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(uiImage: Asset.Icons.upArrow.image)
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: 15,
                    height: 20
                )
                .padding(.vertical, 8)
            
            VStack(spacing: 5) {
                Text(viewModel.currentPrice ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(viewModel.lastPriceUpdateInfo ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Asset.Colors.Redesign.borderGray.color.asColor)
            }
            .frame(width: 70, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Asset.Colors.Redesign.lightGray.color.asColor, lineWidth: 0.5)
        )
    }

    var body: some View {
        VStack {
            VStack {
                Image(uiImage: Asset.Navigation.account.image)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(
                        width: 80,
                        height: 80
                    )
                
                Text(L10n.AccountInfo.Wallet.title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Asset.Colors.lightGray.color.asColor)
                
                Text(viewModel.balance ?? L10n.AccountInfo.Balance.Loading.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            
            qrCode
                .padding(.vertical, 10)
            
            addressView
                .padding(.horizontal, 20)
                .padding(.bottom, 50)

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    shareButton
                    copyButton
                }

                solarPayButton
            }
            .fixedSize()
            
            Spacer()
            
            currentPrice
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            
        }
        .padding(.bottom, 30)
        .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountInfoScene()
    }
}
