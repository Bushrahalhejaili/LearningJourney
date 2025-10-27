//
//  FreezeButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

// Import SwiftUI to access all UI elements and modifiers
import SwiftUI

// MARK: - FreezeButton
// This view adds a button that lets the user “freeze” today’s learning day.
// Freezing a day means they keep their streak safe even if they didn’t learn today.
struct FreezeButton: View {

    // MARK: - Environment Object
    // This gives the view access to the shared ViewModel (`LearningProgressViewModel`),
    // so it can read how many freezes are left and tell the app when to freeze a day.
    @EnvironmentObject private var vm: LearningProgressViewModel

    // MARK: - UI Size Constants
    // These values define the button’s size.
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48

    // MARK: - Logic Properties
    // These computed properties decide how the button looks and behaves.

    // This determines if the button should be disabled.
    // It will be disabled if:
    // 1) The user has already logged today's progress,
    // 2) The user already froze today,
    // 3) The user has no freezes remaining.
    private var isDisabled: Bool {
        vm.isTodayLogged() || vm.isTodayFreezed() || !vm.hasFreezesRemaining
    }

    // The color of the button changes depending on whether the user has freezes left.
    private var buttonColor: Color {
        vm.hasFreezesRemaining ? .lightBlue : .darkishBlue
    }

    // The text below the button tells the user how many freezes have been used.
    // Example: “2 out of 5 Freezes used”
    private var freezeText: String {
        let remaining = vm.freezesRemaining    // How many freezes are left
        let total = vm.maxFreezes              // The total number of freezes allowed
        let used = total - remaining           // How many have been used
        return "\(used) out of \(total) Freezes used"
    }

    // MARK: - Body (UI layout)
    var body: some View {

        // VStack arranges the button and the text vertically
        VStack(spacing: 8) {

            // ------------------------------------------------------------
            // MAIN BUTTON
            // ------------------------------------------------------------
            Button(action: {
                // When the button is tapped, tell the ViewModel to mark today as "frozen".
                // This updates the app’s data and saves the freeze.
                vm.freezeToday()
            }) {
                // The text that appears inside the button
                Text("Log as Freezed")
                    .font(.headline)              // Makes it stand out a bit
                    .foregroundStyle(.white)      // White text color
                    .frame(maxWidth: .infinity)   // Expands the text to fill available space
            }
            // Set the button’s total size
            .frame(width: buttonWidth, height: buttonHeight)

            // Adds a glass effect for a modern, shiny style
            .glassEffect(.clear.tint(.black.opacity(0.65)))

            // Adds a rounded background behind the text
            .background(
                RoundedRectangle(cornerRadius: 1000, style: .continuous)
                    .fill(buttonColor) // Color depends on freezes left
            )

            // Disable the button when necessary (based on `isDisabled`)
            .disabled(isDisabled)

            // ------------------------------------------------------------
            // STATUS TEXT BELOW BUTTON
            // ------------------------------------------------------------
            // This small gray text tells the user how many freezes they've used.
            Text(freezeText)
                .font(.caption)      // Small font size for secondary information
                .foregroundColor(.gray)
        }

        // Make sure everything stays in dark mode for consistent design
        .preferredColorScheme(.dark)
    }
}
