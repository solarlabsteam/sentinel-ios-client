//
//  NavigationBar.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 12.11.2021.
//

import SwiftUI

struct NavigationBar: View {
    var toggleBack: () -> Void
    
    init(toggleBack: @escaping () -> Void) {
        self.toggleBack = toggleBack
    }

    var body: some View {
        ZStack(alignment: .leading) {
        Color.green
            .ignoresSafeArea()
            
            Button(action: toggleBack) {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .foregroundColor(Asset.Colors.navyBlue.color.asColor)
            }
            .frame(width: 60, height: 60)
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(toggleBack: {})
    }
}
