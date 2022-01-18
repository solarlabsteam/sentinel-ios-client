//
//  Image+Ext.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import SwiftUI

extension ImageAsset.Image {
    var asImage: SwiftUI.Image {
        Image(nsImage: self)
    }
}
