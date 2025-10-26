//
//  LogActionButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

import SwiftUI

struct LogActionButton: View {
    var progress: LearningProgress
    
    // Customizable colors
    var defaultBackgroundColor: Color = .richOrange
    var learnedBackgroundColor: Color = .darkishBrown
    var freezedBackgroundColor: Color = .blackishBlue
    var defaultTextColor: Color = .white
    var learnedTextColor: Color = .lightOrange
    var freezedTextColor: Color = .lightBlue
    
    // Customizable text
    var defaultText: String = "Log as Learned"
    var learnedText: String = "Learned Today"
    var freezedText: String = "Day Freezed"
    
    private var buttonText: String {
        if progress.isTodayFreezed() {
            return freezedText
        } else if progress.isTodayLogged() {
            return learnedText
        } else {
            return defaultText
        }
    }
    
    private var buttonTextColor: Color {
        if progress.isTodayFreezed() {
            return freezedTextColor
        } else if progress.isTodayLogged() {
            return learnedTextColor
        } else {
            return defaultTextColor
        }
    }
    
    private var buttonBackgroundColor: Color {
        if progress.isTodayFreezed() {
            return freezedBackgroundColor
        } else if progress.isTodayLogged() {
            return learnedBackgroundColor
        } else {
            return defaultBackgroundColor
        }
    }
    
    var body: some View {
        Button(buttonText) {
            progress.logToday()
        }
        .bold()
        .foregroundStyle(buttonTextColor)
        .font(.system(size: 36))
        .padding(100)
        .background(
            Circle()
                .fill(buttonBackgroundColor.opacity(0.95))
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
        .disabled(progress.isTodayLogged() || progress.isTodayFreezed())
    }
}

#Preview {
    LogActionButton(progress: LearningProgress())
}
