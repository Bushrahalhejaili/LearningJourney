//
//  LogActionButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

// Import SwiftUI — needed to build all user interfaces.
import SwiftUI

// This view shows the big circular "Log as Learned" button on your Activity screen.
// It lets the user mark today as a "Learned" day and changes color/text automatically.
struct LogActionButton: View {

    // MARK: - Connect to the ViewModel
    // We use the shared app ViewModel (LearningProgressViewModel) to know
    // if today is already logged or frozen and to update progress when the button is tapped.
    @EnvironmentObject private var vm: LearningProgressViewModel

    // MARK: - Button Appearance (Colors)
    // These colors define how the button looks in different states.
    // They’re all stored as properties so you can easily adjust them later.
    var defaultBackgroundColor: Color = .richOrange    // Normal state (ready to log)
    var learnedBackgroundColor: Color = .darkishBrown  // After the user logs today
    var freezedBackgroundColor: Color = .blackishBlue  // If today is marked as frozen

    // Text colors for each state
    var defaultTextColor: Color = .white
    var learnedTextColor: Color = .lightOrange
    var freezedTextColor: Color = .lightBlue

    // MARK: - Button Labels (Text)
    // What the button should say in each state
    var defaultText: String = "Log as Learned"   // Before logging
    var learnedText: String = "Learned Today"    // After user logs
    var freezedText: String = "Day Freezed"      // When frozen

    // MARK: - Computed Properties for Current State
    // These computed variables decide what text, color, and background
    // the button should show *right now* based on today’s progress state.

    // 1️⃣ The text that appears inside the button
    private var buttonText: String {
        if vm.isTodayFreezed() {       // Check if today is frozen
            return freezedText
        } else if vm.isTodayLogged() { // Check if today is already learned
            return learnedText
        } else {                       // Otherwise, show default
            return defaultText
        }
    }

    // 2️⃣ The color of the text on the button
    private var buttonTextColor: Color {
        if vm.isTodayFreezed() { return freezedTextColor }
        else if vm.isTodayLogged() { return learnedTextColor }
        else { return defaultTextColor }
    }

    // 3️⃣ The background color of the circle behind the text
    private var buttonBackgroundColor: Color {
        if vm.isTodayFreezed() { return freezedBackgroundColor }
        else if vm.isTodayLogged() { return learnedBackgroundColor }
        else { return defaultBackgroundColor }
    }

    // MARK: - Body (the actual button layout)
    var body: some View {
        // A single large circular button
        Button(buttonText) {
            // What happens when pressed:
            // Ask the ViewModel to log today as "learned"
            // This updates progress and triggers a UI refresh.
            vm.logToday()
        }
        // Make the text bold
        .bold()

        // Use the dynamic text color depending on state
        .foregroundStyle(buttonTextColor)

        // Big, easy-to-tap text
        .font(.system(size: 36))

        // Fixed circular frame size
        .frame(width: 300, height: 300)

        // Background circle with glass and shine effects
        .background(
            Circle() // The round shape of the button
                // Fill it with a slightly see-through color depending on state
                .fill(buttonBackgroundColor.opacity(0.95))

                // Add a shiny, gradient border that simulates light reflection
                .overlay(
                    Circle().strokeBorder(
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
                        ),
                        lineWidth: 1
                    )
                )

                // Apply your app’s custom glass effect (gives a glossy/frosted look)
                .glassEffect(.clear.interactive())
        )

        // Use dark mode so colors match the rest of your app.
        .preferredColorScheme(.dark)

        // Disable the button if the user already logged or froze today.
        // Prevents tapping multiple times for the same day.
        .disabled(vm.isTodayLogged() || vm.isTodayFreezed())
    }
}
