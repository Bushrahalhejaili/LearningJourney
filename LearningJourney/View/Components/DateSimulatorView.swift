//
//  DateSimulatorView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

// Import SwiftUI so we can use its tools to build the user interface.
import SwiftUI

// MARK: - DateSimulatorView
// This view is a small *testing tool* for developers (not for users).
// It lets you manually move the app’s "current day" forward or backward
// so you can test features like streaks and freeze days quickly without waiting in real life.
struct DateSimulatorView: View {

    // MARK: - Properties
    // This variable connects the simulator to the user's progress data.
    // It’s passed in from the parent view (like ActivityView).
    var progress: LearningProgress

    // This is the date currently shown on screen.
    // @State means SwiftUI keeps track of it and updates the screen whenever it changes.
    @State private var displayDate = Date()

    // MARK: - Body (UI layout)
    var body: some View {

        // VStack = vertical stack (places items top to bottom)
        VStack(spacing: 12) { // spacing = 12 points between elements

            // ------------------------------------------------------------
            // Title section (label that shows it’s a testing feature)
            // ------------------------------------------------------------
            Text("🧪 Testing Mode")
                .font(.headline)          // Medium-sized bold text
                .foregroundColor(.yellow) // Yellow to warn users it’s not for production

            // ------------------------------------------------------------
            // Show the current simulated date
            // ------------------------------------------------------------
            Text(displayDate, style: .date) // Displays only the date (not time)
                .font(.headline)
                .foregroundColor(.white)

            // ------------------------------------------------------------
            // Navigation buttons for changing the date
            // ------------------------------------------------------------
            HStack(spacing: 16) {
                // Button 1: Go back one day
                Button {
                    // Tell the LearningProgress model to move one day backward
                    progress.goToPreviousDay()
                    // Update what’s shown on screen
                    updateDisplayDate()
                } label: {
                    // The arrow icon for going backward
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }

                // Button 2: Reset to the real current date
                Button("Today") {
                    // Tell the model to reset its date to the actual system date
                    progress.resetToRealDate()
                    // Update what’s shown on screen
                    updateDisplayDate()
                }
                .foregroundColor(.white)

                // Button 3: Advance one day forward
                Button {
                    // Move the simulated date forward by one day
                    progress.advanceToNextDay()
                    // Update the displayed date after changing it
                    updateDisplayDate()
                } label: {
                    // The arrow icon for going forward
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
        }

        // When this view first appears on screen, make sure the displayed date matches the model’s date
        .onAppear {
            updateDisplayDate()
        }
    }

    // MARK: - Helper Function
    // This private function updates the displayed date to match the model’s simulated date.
    private func updateDisplayDate() {
        // Check if the model has a simulated date (optional),
        // otherwise use the actual current date.
        displayDate = progress.simulatedDate ?? Date()
    }
}

// MARK: - Preview
// Lets you preview this view inside Xcode without running the full app.
#Preview {
    DateSimulatorView(progress: LearningProgress())
        .preferredColorScheme(.dark) // Use dark mode for visual consistency
}
