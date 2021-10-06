//
//  OnboardingStepView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 27.08.2021.
//

import Foundation
import SwiftUI

struct OnboardingStepView: View {
    private let model: OnboardingStepModel

    init(model: OnboardingStepModel) {
        self.model = model
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Text(model.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()

                Text(model.description)
                    .font(.system(size: 16, weight: .light))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Asset.Colors.Redesign.lightGray.color.asColor)
                    .padding()

                Spacer()

                Image(model.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(
                        width: geo.size.width * 0.8,
                        height: geo.size.height * 0.5,
                        alignment: .center
                    )

                Spacer()

            }
        }
    }
}
