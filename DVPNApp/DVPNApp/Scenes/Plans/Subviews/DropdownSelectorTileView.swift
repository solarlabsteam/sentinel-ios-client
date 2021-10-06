//
//  DropdownSelectorTileView.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI
import FlagKit

struct DropdownSelectorTileView: View {
    private let icon: UIImage
    private let description: String
    private let title: String
    
    init(
        icon: UIImage,
        description: String,
        title: String
    ) {
        self.icon = icon
        self.description = description
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 5) {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                Spacer()
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .opacity(0.5)
            }
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.bottom, 5)
                
                Spacer()
                
                Image(systemName: "chevron.down.circle.fill")
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white.opacity(0.5))
            }
            
        }
        .foregroundColor(.white)
        .padding(.all, 10)
        .background(MainGradient())
        .cornerRadius(6)
    }
}

struct DropdownSelectorTileView_Previews: PreviewProvider {
    static var previews: some View {
        DropdownSelectorTileView(icon: Flag(countryCode: "CH")!.image(style: .circle), description: "Country", title: "Swizerland")
    }
}
