//
//  LogActionButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

import SwiftUI

struct LogActionButton: View {
    var body: some View {
        Button("Log as Learned") {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
        }
        .bold()
        .foregroundStyle(Color.white)
        .font(.system(size: 36))
        .padding(100)
        .background(
            Circle()
                .fill(Color.richOrange.opacity(0.95))
                .overlay(
                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.4),
                                    Color.white.opacity(0.6),
                                    Color.black.opacity(0.2),
                                    Color.white.opacity(0.9),
                                    Color.black.opacity(0.2),
                                    Color.black.opacity(0.4)
                                ]),
                                center: .center
                            ),  lineWidth: 1
                            
                        )
                )
                .glassEffect(.clear.interactive())
            
        )
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LogActionButton()
}
