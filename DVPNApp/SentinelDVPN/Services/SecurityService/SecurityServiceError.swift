//
//  SecurityServiceError.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.11.2021.
//

import Foundation

enum SecurityServiceError: LocalizedError {
    case emptyInput
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return L10n.SecurityService.Error.emptyInput
        case .invalidInput:
            return L10n.SecurityService.Error.invalidInput
        }
    }
}
