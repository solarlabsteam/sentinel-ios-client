//
//  UIViewController+NavigationBar.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 16.08.2021.
//

import UIKit

enum NavigationBarStyle {
    case `default`
}

// MARK: - Adaptation of controller's navigation bar for app's design

extension UIViewController {
    private static func applyNavigationBar(
        style: NavigationBarStyle,
        to navigationController: UINavigationController
    ) {
        switch style {
        case .default:
            navigationController.navigationBar.applyDefaultStyle()
        }
    }

    func makeNavigationBar(hidden: Bool, animated: Bool, style: NavigationBarStyle? = .default) {
        let applyStyle: (UINavigationController) -> Void = { controller in
            if animated {
                UIView.animate(withDuration: 0.3) {
                    style.map { Self.applyNavigationBar(style: $0, to: controller) }
                }
            } else {
                style.map { Self.applyNavigationBar(style: $0, to: controller) }
            }
            controller.setNavigationBarHidden(hidden, animated: animated)
        }

        if let navigationController = navigationController {
            resetBackBarButton()

            let stylist = NavigationBarStylist(applyStyle: applyStyle)
            let styleManager = NavigationControllerStyleManager.shared
            navigationController.delegate = styleManager
            styleManager.addStylist(stylist, for: self)
        } else if let navigationController = self as? UINavigationController {
            applyStyle(navigationController)
        }
    }
}

private extension UIViewController {
    func resetBackBarButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil
        )
    }
}

final class NavigationControllerStyleManager: NSObject, UINavigationControllerDelegate {
    static let shared = NavigationControllerStyleManager()

    private var stylists = NSMapTable<UIViewController, NavigationBarStylist>(keyOptions: .weakMemory,
                                                                              valueOptions: .strongMemory)

    private override init() {}

    func addStylist(_ stylist: NavigationBarStylist, for controller: UIViewController) {
        stylists.setObject(stylist, forKey: controller)
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        let forbiddenStates: [UIGestureRecognizer.State] = [.began, .recognized]
        if let state = navigationController.interactivePopGestureRecognizer?.state,
            !forbiddenStates.contains(state) || navigationController.interactivePopGestureRecognizer == nil {
            stylists.object(forKey: viewController).map { $0.applyStyle(navigationController) }
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        stylists.object(forKey: viewController).map { $0.applyStyle(navigationController) }
    }
}

final class NavigationBarStylist {
    let applyStyle: (UINavigationController) -> Void

    init(applyStyle: @escaping (UINavigationController) -> Void) {
        self.applyStyle = applyStyle
    }
}
