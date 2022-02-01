//
//  ContentView.swift
//  SentinelDVPN
//
//  Created by Viktoriia Kostyleva on 18.01.2022.
//

import SwiftUI

struct ContentView: View {
    @State var showAccountPopover = false
    
    var body: some View {
        NavigationView {
            ModulesFactory.shared.makeConnectionScene()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { self.showAccountPopover.toggle() }) {
                    Asset.Navigation.account.image.asImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .popover(isPresented: self.$showAccountPopover, arrowEdge: .bottom) {
                    ModulesFactory.shared.makeAccountInfoScene()
                }
                .buttonStyle(PlainButtonStyle())
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
