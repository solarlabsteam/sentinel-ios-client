//
//  PageIndicator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 21.10.2021.
//

import SwiftUI

/// The union of all layout constants, colors, font sizes etc.

private struct Constants {
    let width: CGFloat = 8
    let selectedWidth: CGFloat = 28

    let cornerRadius: CGFloat = 4

    let spacing: CGFloat = 6

    let accentColor = Asset.Colors.navyBlue.color.asColor
    let borderColor = Asset.Colors.lightGray.color.asColor.opacity(0.5)
}

private let constants = Constants()

// MARK: - PageDot

struct PageDot<T: Equatable>: View {
    private let index: T
    @Binding var currentPage: T

    init(index: T, currentPage: Binding<T>) {
        self.index = index
        self._currentPage = currentPage
    }

    private var isSelected: Bool {
        currentPage == index
    }

    var body: some View {
        Button(action: {
            currentPage = index
        }) {
            RoundedRectangle(cornerRadius: constants.cornerRadius)
                .foregroundColor(
                    isSelected ?
                    constants.accentColor : .clear
                )
                .animation(.interactiveSpring())
                .overlay(
                    RoundedRectangle(cornerRadius: constants.cornerRadius)
                        .stroke(isSelected ? .clear : constants.borderColor, lineWidth: 1)
                )
                .frame(
                    width: isSelected ? constants.selectedWidth : constants.width,
                    height: constants.width
                )
        }
    }
}

// MARK: - PageIndicator

struct PageIndicator<T: Hashable & Equatable>: View {
    private let pages: [T]
    @Binding var currentPage: T

    init(pages: [T], currentPage: Binding<T>) {
        self.pages = pages
        self._currentPage = currentPage
    }

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: constants.spacing) {
                ForEach(pages, id: \.self) {
                    PageDot(
                        index: $0,
                        currentPage: $currentPage
                    )
                }
            }
        }
    }
}
