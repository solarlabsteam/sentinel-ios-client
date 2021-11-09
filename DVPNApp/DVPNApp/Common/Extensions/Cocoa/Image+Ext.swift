//
//  Image+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import SwiftUI

extension ImageAsset.Image {
#if os(macOS)
    var asImage: SwiftUI.Image {
        Image(nsImage: self)
    }
#elseif os(iOS)
    var asImage: SwiftUI.Image {
        Image(uiImage: self)
    }
#endif
}
