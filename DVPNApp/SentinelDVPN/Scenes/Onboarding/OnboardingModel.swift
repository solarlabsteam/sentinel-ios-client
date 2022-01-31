//
//  OnboardingModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 11.08.2021.
//

import Combine
import SentinelWallet

enum OnboardingModelEvent { }

final class OnboardingModel {
    typealias Context = HasSecurityService
    private let context: Context

    private let eventSubject = PassthroughSubject<OnboardingModelEvent, Never>()
    var eventPublisher: AnyPublisher<OnboardingModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }
}
