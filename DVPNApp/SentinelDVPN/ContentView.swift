//
//  ContentView.swift
//  SentinelDVPN
//
//  Created by Viktoriia Kostyleva on 18.01.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ModulesFactory.shared.makeNodeSelectionModule()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Asset.Navigation.account.image.asImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 25, height: 25)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
