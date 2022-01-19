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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
