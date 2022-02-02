//
//  CreationMode.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Foundation

enum CreationMode {
    case restore
    case create

    var title: String {
        switch self {
        case .create:
            return L10n.AccountCreation.Create.title
        case .restore:
            return L10n.AccountCreation.Import.title
        }
    }

    var buttonTitle: String {
        switch self {
        case .create:
            return L10n.AccountCreation.Create.button
        case .restore:
            return L10n.AccountCreation.Import.button
        }
    }
}
