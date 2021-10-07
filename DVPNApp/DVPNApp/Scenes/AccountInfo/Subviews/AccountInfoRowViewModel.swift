//
//  AccountInfoRowViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import UIKit

struct AccountInfoRowViewModel: Hashable {
    let id: String
    let server: String
    var isSelected: Bool
    let icon: UIImage
    let title: String

    init(
        id: String,
        server: String,
        isSelected: Bool,
        icon: UIImage,
        title: String
    ) {
        self.id = id
        self.server = server
        self.isSelected = isSelected
        self.icon = icon
        self.title = title
    }
}
