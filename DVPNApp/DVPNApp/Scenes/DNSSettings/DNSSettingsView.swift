//
//  DNSSettingsView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#endif
import FlagKit

struct DNSSettingsView: View {

    @ObservedObject private var viewModel: DNSSettingsViewModel

    init(viewModel: DNSSettingsViewModel) {
        self.viewModel = viewModel

#if os(iOS)
        UITableViewCell.appearance().selectionStyle = .none
#endif
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Button(action: viewModel.didTapClose) {
                Image(systemName: "multiply")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())

            VStack {
                Text(L10n.Dns.title)
                    .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                    .padding()

                ForEach(Array(zip(viewModel.items.indices, viewModel.items)), id: \.0) { index, model in
                    DNSSettingsRowView(
                        model: model,
                        toggleSelection: { viewModel.toggleSelection(with: model.type) }
                    )
                        .padding()

                    if index != viewModel.items.count - 1 {
                        Divider()
                            .background(Asset.Colors.lightBlue.color.asColor)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Asset.Colors.accentColor.color.asColor)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.Colors.lightBlue.color.asColor, lineWidth: 1)
            )
            .padding(.all, 28)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.accentColor.color.asColor.opacity(0.85))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DNSSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getDNSSettingsScene()
    }
}
