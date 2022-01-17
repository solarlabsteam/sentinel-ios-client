//
//  AccountInfoView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import SwiftUI

private struct Constants {
    let coordinateSpaceName = "pullToRefresh"
}

private let constants = Constants()

struct AccountInfoView: View {

    @ObservedObject private var viewModel: AccountInfoViewModel
    
    @Environment(\.openURL) var openURL

    init(viewModel: AccountInfoViewModel) {
        self.viewModel = viewModel
    }
    
    var accountImage: some View {
        Asset.Navigation.account.image.asImage
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(
                width: 100,
                height: 100
            )
    }

    var addressView: some View {
        Button(action: viewModel.didTapCopy) {
            HStack(alignment: .center, spacing: 3) {
                Spacer()
                
                Text(viewModel.address)
                    .applyTextStyle(.whitePoppins(ofSize: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
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
#if os(iOS)
            UIImpactFeedbackGenerator.lightFeedback()
#endif
            openURL(viewModel.solarPayURL)
        }
    }

    var qrCode: some View {
        VStack(alignment: .center, spacing: nil) {
            Color.white
                .mask(
                    viewModel.qrCode.asImage
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .frame(width: 150, height: 150)
            
            Text(L10n.AccountInfo.qr)
                .applyTextStyle(.grayPoppins(ofSize: 12, weight: .regular))
        }
    }
    
    var currentPrice: some View {
        HStack {
            Text(L10n.AccountInfo.currentPrice)
                .applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
            
            Spacer()
            
            viewModel.priceArrowImage.asImage
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: 15,
                    height: 20
                )
                .padding(.vertical, 16)
            
            VStack(spacing: 5) {
                Text(viewModel.currentPrice ?? "")
                    .applyTextStyle(.whitePoppins(ofSize: 16, weight: .bold))
                Text(viewModel.lastPriceUpdateInfo ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .regular))
            }
            .frame(width: 80, height: 30, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Asset.Colors.lightGray.color.asColor, lineWidth: 0.5)
        )
    }

    var body: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: constants.coordinateSpaceName) {
                 viewModel.refresh()
             }
            
            VStack {
                accountImage
                
                Text(L10n.AccountInfo.Wallet.title)
                    .applyTextStyle(.grayPoppins(ofSize: 12, weight: .regular))
                
                HStack {
                    Text(viewModel.balance ?? "-")
                        .applyTextStyle(.whitePoppins(ofSize: 22, weight: .bold))
                    
                    Text(L10n.Common.Dvpn.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .applyTextStyle(.whitePoppins(ofSize: 22, weight: .regular))
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
            
            currentPrice
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            
        }
#if os(iOS)
        .coordinateSpace(name: constants.coordinateSpaceName)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.refresh()
        }
#endif
        .padding(.bottom, 30)
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountInfoScene()
    }
}
