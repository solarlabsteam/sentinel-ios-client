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
        
        UIScrollView.appearance().bounces = false
    }

    var addressView: some View {
        Button(action: viewModel.didTapCopy) {
            HStack(alignment: .center, spacing: 3) {
                Spacer()
                
                Text(viewModel.address)
                    .applyTextStyle(.whiteMain(ofSize: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Asset.Colors.lightBlue.color.asColor, lineWidth: 0.5)
        )
    }
    
    var shareButton: some View {
        FramedButton(title: L10n.AccountInfo.share) {
            viewModel.didTapShare()
        }
    }
    
    var copyButton: some View {
        FramedButton(title: L10n.AccountInfo.copy) {
            viewModel.didTapCopy()
        }
    }
    
    var solarPayButton: some View {
        AccentButton(title: L10n.AccountInfo.topUp) {
            viewModel.didTapTopUp()
        }
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
                .applyTextStyle(.grayMain(ofSize: 12, weight: .regular))
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                Text(L10n.AccountInfo.Wallet.title)
                    .applyTextStyle(.grayMain(ofSize: 12, weight: .regular))
                    .padding(.top, 20)
                
                HStack {
                    Text(viewModel.balance ?? "-")
                        .applyTextStyle(.whiteMain(ofSize: 22, weight: .bold))
                    
                    Text(" " + L10n.Common.Dvpn.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .applyTextStyle(.whiteMain(ofSize: 22, weight: .regular))
                }
            }
            .padding(.bottom, 8)
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
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.refresh()
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountInfoScene()
    }
}
