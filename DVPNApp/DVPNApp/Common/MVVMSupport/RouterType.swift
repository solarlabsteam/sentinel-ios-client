//
//  RouterType.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 27.07.2021.
//

import Foundation
#if os(macOS)
import Cocoa
#elseif os(iOS)
import SwiftMessages
import class UIKit.UIViewController
#endif

protocol RouterType {
    associatedtype Event

    /// Handle a coordinator event.
    func play(event: Event)
}

#if os(iOS)
extension RouterType {
    func show(
        message: String,
        theme: Theme = .error,
        presentationContext: SwiftMessages.PresentationContext = .automatic
    ) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(theme)
        view.button?.backgroundColor = .clear
        view.configureContent(
            title: nil,
            body: message,
            iconImage: nil,
            iconText: nil,
            buttonImage: nil,
            buttonTitle: nil,
            buttonTapHandler: nil
        )

        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 4)
        config.presentationContext = presentationContext

        SwiftMessages.show(config: config, view: view)
    }
}
#elseif os(macOS)
extension RouterType {
    func showErrorAlert(
        message: String,
        type: NSAlert.Style = .critical
    ) {
        let alert = NSAlert()
        alert.messageText = type == .critical ? L10n.Common.Error.title : L10n.Common.Warning.title
        alert.informativeText = message
        alert.alertStyle = type
        alert.addButton(withTitle: L10n.Action.ok)
        alert.runModal()
    }
}
#endif

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
