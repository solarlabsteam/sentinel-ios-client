//
//  CheckmarkToggleStyle.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 30.08.2021.
//

import SwiftUI

struct ConnectionToggleStyle: ToggleStyle {
    typealias ImageSource = Asset.Home.Toggle
    @Binding var isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 90, height: 130, alignment: .center)
                .overlay(
                    VStack {
                        if !configuration.isOn {
                            if isLoading {
                                ActivityIndicator(isAnimating: $isLoading, style: .medium)
                                    .frame(width: 15, height: 15)
                                    .padding(.vertical, 20)
                            } else {
                                Image(uiImage: Asset.Home.Toggle.Arrow.up.image)
                                    .frame(width: 15, height: 15)
                                    .padding(.vertical, 20)
                            }
                        }

                        Circle()
                            .foregroundColor(Asset.Colors.Redesign.navyBlue.color.asColor)
                            .overlay(
                                Image(ImageSource.power.name)
                                    .resizable()
                                    .padding(26)
                                    .aspectRatio(contentMode: .fit)
                            )
                            .offset(x: 0, y: configuration.isOn ? 10 : -10)
                            .animation(Animation.linear(duration: 0.1))
                            .gesture(
                                DragGesture()
                                    .onEnded { _ in
                                        configuration.isOn.toggle() }
                            )
                            .frame(width: 80, height: 80)

                        if configuration.isOn {
                            if isLoading {
                                ActivityIndicator(isAnimating: $isLoading, style: .medium)
                                    .frame(width: 15, height: 15)
                                    .padding(.vertical, 20)
                            } else {
                                Image(uiImage: Asset.Home.Toggle.Arrow.down.image)
                                    .frame(width: 15, height: 15)
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                )
                .background(
                    Asset.Colors.Redesign.prussianBlue.color.asColor
                )
                .cornerRadius(40)
                .onTapGesture { configuration.isOn.toggle() }
    }
}

struct ConnectionToggleStyleView: View {
    @State private var showGreeting = true
    @State private var isLoading = true

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Toggle("", isOn: $showGreeting)
                    .labelsHidden()
                    .toggleStyle(ConnectionToggleStyle(isLoading: $isLoading))
                Spacer()
            }
            Spacer()
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct ConnectionToggleStyleView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionToggleStyleView()
    }
}
