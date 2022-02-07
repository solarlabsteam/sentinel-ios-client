//
//  RouterType.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 27.07.2021.
//

import Foundation
import Cocoa

protocol RouterType {
    associatedtype Event

    /// Handle a coordinator event.
    func play(event: Event)
}

extension RouterType {
    func showErrorAlert(
        message: String,
        type: NSAlert.Style = .critical
    ) {
        let alert = NSAlert()
        alert.messageText = type == .critical ? L10n.Common.Error.title : L10n.Common.Warning.title
        alert.informativeText = message
        alert.alertStyle = type
        alert.addButton(withTitle: L10n.Common.ok)
        alert.runModal()
    }
}

final class AnyRouter<Event>: RouterType {
    private let _playEvent: (Event) -> Void

    init<C>(_ coordinator: C) where C: RouterType,
        C.Event == Event {
        self._playEvent = coordinator.play(event:)
    }

    init(play: @escaping (Event) -> Void) {
        self._playEvent = play
    }

    func play(event: Event) {
        _playEvent(event)
    }
}

extension RouterType {
    /// Type-erase any RouterType-compliant instance.
    func asRouter() -> AnyRouter<Event> {
        return .init(self)
    }
}
