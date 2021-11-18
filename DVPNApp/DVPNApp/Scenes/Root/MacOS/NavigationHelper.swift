//
//  NavigationHelper.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.11.2021.
//

import Cocoa
import SwiftUI
import SnapKit

protocol ListNavigationControllerType: AnyObject {
    var items: [NSView] { get }
}

final class NavigationHelper: ListNavigationControllerType {
    private(set) var items: [NSView] = []
    
    private let window: NSWindow
    private let containerView: NSView
    private var backButtonView: NSView?
    
    init(window: NSWindow) {
        self.window = window
        
        containerView = NSView()
        window.contentView = containerView
        
        addBackButton()
    }
    
    func push(view: NSView, clearStack: Bool = false) {
        if clearStack {
            items.forEach { $0.removeFromSuperview() }
            items = []
        }
        items.append(view)
        backButtonView?.isHidden = items.count == 1
        
        add(subview: view)
    }

    func present(view: NSView) {
        items.append(view)
        backButtonView?.isHidden = true

        containerView.addSubview(view)

        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func pop() {
        let item = items.removeLast()
        item.removeFromSuperview()
        
        backButtonView?.isHidden = items.count == 1
    }
    
    private func addBackButton() {
        let barView = NavigationBar(toggleBack: { [weak self] in self?.pop() })
        let barHostingView = NSHostingView(rootView: barView)
        
        containerView.addSubview(barHostingView)
        
        barHostingView.snp.makeConstraints { make in
            make.top.leading.width.equalToSuperview()
        }
        
        barHostingView.isHidden = true
        
        backButtonView = barHostingView
    }
    
    private func add(subview: NSView) {
        containerView.addSubview(subview, positioned: .below, relativeTo: backButtonView)
        
        subview.snp.makeConstraints { make in
            make.centerX.bottom.leading.equalToSuperview()
            
            guard let backButtonView = backButtonView, !backButtonView.isHidden else {
                make.top.equalToSuperview()
                return
            }
            make.top.equalTo(backButtonView.snp.bottom)
        }
    }
}
