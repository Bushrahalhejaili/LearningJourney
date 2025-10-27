//
//  NewGoalButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

// Import SwiftUI so we can build and style our interface.
import SwiftUI

// This small view shows two buttons that appear when the user has completed a goal:
// 1) A button to set a brand-new goal.
// 2) A button to reuse the same goal and duration again.
struct NewGoalButton: View {

    // MARK: - ViewModel connection
    // This connects to the shared ViewModel (the "brain" of the app)
    // that keeps track of the user's progress and goals.
    // @EnvironmentObject means this variable is automatically filled
    // by whatever ViewModel was provided from above in the navigation stack.
    @EnvironmentObject private var vm: LearningProgressViewModel

    // MARK: - Local state
    // Keeps track of whether we should navigate to the LearningGoalView screen.
    // @State means SwiftUI will update the view automatically if this value changes.
    @State private var goToLearningGoal = false

    // MARK: - Button styling constants
    // These are just size values to make the button match your design.
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48
    
    // MARK: - Body (the layout)
    var body: some View {
        // VStack arranges the two buttons vertically (one above the other).
        VStack {

            // ------------------------------------------------------------
            // FIRST BUTTON: "Set new learning goal"
            // ------------------------------------------------------------
            // When tapped, we set goToLearningGoal = true
            // which triggers navigation to the LearningGoalView screen.
            Button { goToLearningGoal = true } label: {
                // The visible part of the button.
                Text("Set new learning goal")
                    .font(.custom("SF Pro", size: 17)) // Custom font and size.
                    .foregroundStyle(.white)           // White text color.
                    .frame(width: buttonWidth, height: buttonHeight) // Fixed size.
                    // Adds your glass-style transparency overlay.
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    // Rounded background with your orange color.
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(Color.lightOrange)
                    )
                    // Adds some space around the button so it doesn’t stick to edges.
                    .padding()
            }
            // ------------------------------------------------------------
            // Navigation link setup
            // ------------------------------------------------------------
            // This modifier tells SwiftUI: “When goToLearningGoal becomes true,
            // navigate to another screen called LearningGoalView.”
            .navigationDestination(isPresented: $goToLearningGoal) {
                // The destination view — it appears when the button is pressed.
                LearningGoalView(isUpdatingMidway: false)
                    .navigationTitle("Learning Goal")              // Title in navigation bar.
                    .navigationBarTitleDisplayMode(.inline)         // Compact title style.
            }

            // ------------------------------------------------------------
            // SECOND BUTTON: "Set same learning goal and duration"
            // ------------------------------------------------------------
            // This one doesn’t open another screen — it just calls a ViewModel function.
            Button("Set same learning goal and duration") {
                // Call the ViewModel’s function to reset the goal but keep the history.
                // This means: the user starts again with the same topic/duration.
                vm.resetGoalKeepHistory()
            }
            // Set the same text font for consistency.
            .font(.custom("SF Pro", size: 17))
            // Make the text color orange to show it’s a secondary action.
            .foregroundStyle(.lightOrange)
        }
        // Force dark mode so colors match your app’s design.
        .preferredColorScheme(.dark)
    }
}
