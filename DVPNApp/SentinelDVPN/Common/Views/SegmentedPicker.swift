//
//  SegmentedPicker.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 17.02.2022.
//

import SwiftUI

// MARK: - SegmentedPickerElementView

struct SegmentedPickerElementView<Content>: View where Content: View {
    let content: () -> Content
    
    init(
        @ViewBuilder
        content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            self.content()
                .fixedSize(horizontal: true, vertical: true)
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
                .contentShape(Rectangle())
        }
    }
}

private struct Constants {
    let cornerRadius: CGFloat = 6
    let factor: CGFloat = 1 // from 0 to 1
    
    let color = Asset.Colors.deepBlue.color.asColor
    let selectedColor = Asset.Colors.navyBlue.color.asColor
}

private let constants = Constants()

// MARK: - SegmentedPickerView

struct SegmentedPickerView<SelectionValue>: View where SelectionValue: Hashable {
    let elements: [(id: SelectionValue, view: AnyView)]

    @Binding var selectedElement: SelectionValue

    private let width: CGFloat = 500
    private let height: CGFloat = 35
    
    init(_ selectedElement: Binding<SelectionValue>, elements: [(id: SelectionValue, view: AnyView)]) {
        self._selectedElement = selectedElement
        
        self.elements = elements
    }

    var body: some View {
        ZStack(alignment: .leading) {
            selectedForm
            picker
        }
        .frame(width: self.width, height: self.height)
        .background(constants.color)
        .cornerRadius(constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: constants.cornerRadius)
                .stroke(Asset.Colors.navyBlue.color.asColor, lineWidth: 1)
        )
    }
}

extension SegmentedPickerView {
    var selectedForm: some View {
        Rectangle()
            .foregroundColor(constants.selectedColor)
            .cornerRadius(constants.cornerRadius * constants.factor)
            .frame(
                width: self.width * constants.factor / CGFloat(self.elements.count),
                height: self.height - self.width * (1 - constants.factor)
            )
            .offset(x: calculateXOffset())
            .animation(.easeInOut(duration: 0.2))
    }
    
    var picker: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(self.elements, id: \.id) { item in
                item.view
                    .gesture(TapGesture().onEnded { _ in
                        self.selectedElement = item.id
                    })
            }
        }
    }
    
    private func calculateXOffset() -> CGFloat {
        let itemWidth = CGFloat(self.width / CGFloat(self.elements.count))
        let indexOfSelectedElement = elements.firstIndex(where: { $0.id == self.selectedElement })
        let offset = (itemWidth * CGFloat(indexOfSelectedElement ?? 0))
        
        return offset
    }
}

// MARK: - Preview

struct SegmentedPickerView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPickerView(
            .constant(1),
            elements: [
                (id: 0, view: AnyView(SegmentedPickerElementView {
                    Text("0").applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                })),
                (id: 1, view: AnyView(SegmentedPickerElementView {
                    Text("1").applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                }))
            ]
        )
    }
}
