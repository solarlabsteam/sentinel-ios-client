//
//  AccountInfoView.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import SwiftUI
import AlertToast

private struct Constants {
    let coordinateSpaceName = "pullToRefresh"
}

private let constants = Constants()

struct AccountInfoView: View {
    @ObservedObject private var viewModel: AccountInfoViewModel
    @State private var showPicker = false
    
    @Environment(\.openURL) var openURL

    init(viewModel: AccountInfoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: constants.coordinateSpaceName) {
                 viewModel.refresh()
             }
            
            VStack {
                Text(L10n.AccountInfo.Wallet.title)
                    .applyTextStyle(.grayPoppins(ofSize: 12, weight: .regular))
                
                HStack {
                    Text(viewModel.balance ?? "-")
                        .applyTextStyle(.whitePoppins(ofSize: 22, weight: .regular))
                    
                    Text(L10n.Common.Dvpn.title)
                        .foregroundColor(.white)
                        .applyTextStyle(.whitePoppins(ofSize: 22, weight: .regular))
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            
            qrCode
                .padding(.vertical, 10)
            
            addressView
                .padding(.horizontal, 20)
                .padding(.bottom, 40)

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    shareButton
                    copyButton
                }

                solarPayButton
            }
            .fixedSize()
        }
        .padding(.bottom, 30)
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
        .toast(isPresenting: $viewModel.alertContent.isShown) {
            viewModel.alertContent.toast
        }
    }
}

// MARK: - Subviews

extension AccountInfoView {
    private var addressView: some View {
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
    
    // MARK: - Buttons
    
    private var shareButton: some View {
        FramedButton(title: L10n.AccountInfo.share) {
            self.showPicker = true
        }
        .background(
            SharingPicker(isPresented: $showPicker, sharingItems: [viewModel.address])
        )
    }
    
    private var copyButton: some View {
        FramedButton(title: L10n.AccountInfo.copy) {
            viewModel.didTapCopy()
        }
    }
    
    private var solarPayButton: some View {
        AccentButton(title: L10n.AccountInfo.topUp) {
            openURL(viewModel.solarPayURL)
        }
    }
    
    // MARK: - QR code

    private var qrCode: some View {
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
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getAccountInfoScene()
    }
}
