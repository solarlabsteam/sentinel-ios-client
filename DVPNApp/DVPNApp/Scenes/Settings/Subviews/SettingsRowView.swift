//
//  SettingsRowView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import SwiftUI

struct SettingsRowView: View {

    private var viewModel: SettingsRowViewModel
    private var toggleSelection: () -> Void

    init(
        viewModel: SettingsRowViewModel,
        toggleSelection: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.toggleSelection = toggleSelection
    }

    var body: some View {
        Button(action: {
            toggleSelection()
        }, label: {
            Image(uiImage: viewModel.icon)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.trailing, 4)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(viewModel.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Image(
                viewModel.isSelected ? Asset.Settings.radioButtonSelected.name : Asset.Settings.radioButtonUnselected.name
            ).frame(width: 20, height: 20)
            
        })
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
