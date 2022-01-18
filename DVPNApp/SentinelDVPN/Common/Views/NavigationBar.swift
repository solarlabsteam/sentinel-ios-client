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
        HStack {
            Button(action: toggleBack) {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Asset.Colors.navyBlue.color.asColor)
            }
            .frame(width: 20, height: 20)
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.all, 10)
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(toggleBack: {})
    }
}
