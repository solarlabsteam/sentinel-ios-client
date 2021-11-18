//
//  List+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 18.11.2021.
//

import SwiftUI
import Introspect

extension List {
    /// List on macOS uses an opaque background with no option for
    /// removing/changing it. listRowBackground() doesn't work either.
    /// This workaround works because List is backed by NSTableView.
    func removeBackground() -> some View {
        return introspectTableView { tableView in
            tableView.backgroundColor = .clear
            tableView.enclosingScrollView!.drawsBackground = false
        }
    }
}
