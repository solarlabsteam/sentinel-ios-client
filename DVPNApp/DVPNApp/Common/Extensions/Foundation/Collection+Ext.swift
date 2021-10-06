//
//  Collection+Ext.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
