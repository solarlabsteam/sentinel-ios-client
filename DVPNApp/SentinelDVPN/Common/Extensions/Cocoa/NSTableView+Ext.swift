//
//  NSTableView+Ext.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 19.11.2021.
//

import Cocoa

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
