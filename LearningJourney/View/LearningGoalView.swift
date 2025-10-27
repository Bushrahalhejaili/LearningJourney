//
//  LearningGoalView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 24/10/2025.
//

// We need SwiftUI to build the screen (UI).
import SwiftUI

// This defines a new screen (a View) called LearningGoalView.
struct LearningGoalView: View {
    // We access the shared ViewModel from the environment.
    // Think of the ViewModel as the "brain" that stores data and functions.
    // @EnvironmentObject means: "This view expects someone above to provide the ViewModel."
    @EnvironmentObject private var vm: LearningProgressViewModel

    // This flag tells us if the user is changing the goal while a goal is already running.
    // If true, we might show a warning before changing.
    var isUpdatingMidway: Bool = false

    // Text typed by the user into the text field lives here.
    // @State means SwiftUI should redraw the screen if this value changes.
    @State private var learningTopic: String = ""

    // An enum is a custom type with a few possible values (choices).
    // Here, the user can pick Week, Month, or Year.
    enum goalDuration { case Week , Month , Year }

    // Which duration has the user picked? (Might be nil if they haven't picked yet.)
    @State private var goal: goalDuration?

    // Should we show the warning pop-up (alert)? Stored as state too.
    @State private var showWarning: Bool = false

    // This gives us a dismiss() function that closes the current screen.
    @Environment(\.dismiss) var dismiss

    // Add this init
    // This custom initializer lets the parent screen set "isUpdatingMidway" when creating this view.
    init(isUpdatingMidway: Bool = false) {
        // Store the incoming value into our property.
        self.isUpdatingMidway = isUpdatingMidway
    }
    
    // ---- Styling variables (just numbers/colors for the UI) ----

    // Which font the text field should use.
    var textFieldFont: Font = .title3

    // What color the text inside the text field should be.
    var textFieldTextColor: Color = Color(.white)

    // This computed variable turns the selected enum into a text label.
    // If goal is Week → "Week", Month → "Month", Year → "Year".
    // If nothing is picked yet, return empty string.
    private var durationLabel: String {
        switch goal {
        case .Week:  return "Week"
        case .Month: return "Month"
        case .Year:  return "Year"
        case .none:  return ""
        }
    }

    // The body describes what the screen looks like every time the data changes.
    var body: some View {
        // VStack stacks views vertically (top to bottom) with spacing between groups below.
        VStack(spacing: 24) {

            // First section: the "I want to learn" label and the text field.
            VStack(alignment: .leading, spacing: 4) {
                // This is just the label above the text field.
                Text("I want to learn")
                    .foregroundColor(Color(.white)) // Make the text white
                    .font(.title2)                   // Make the text bigger

                // The text field the user types into.
                // The $ means "bind this text field to the @State variable".
                TextField("Swift", text: $learningTopic)
                    .font(textFieldFont)                 // Use the font we chose
                    .foregroundColor(textFieldTextColor) // Use the color we chose
                    .textInputAutocapitalization(.words) // Capitalize each word automatically
                    .disableAutocorrection(true)         // Turn off spell check/autocorrect
            }
            // Make this section stretch to full width and align its content to the left.
            .frame(maxWidth: .infinity, alignment: .leading)

            // Second section: "I want to learn it in a" and the three buttons (Week/Month/Year)
            VStack(alignment: .leading, spacing: 12) {
                // Label above the buttons
                Text("I want to learn it in a")
                    .foregroundColor(Color(.white))
                    .font(.title2)

                // HStack lays out the three buttons horizontally (left to right)
                HStack {
                    // Button 1: Week
                    // When tapped, if Week was already selected, turn it off (nil). Otherwise select Week.
                    Button { goal = goal == .Week  ? nil : .Week  }  label: {
                        // The visible text inside the button
                        Text("Week")
                            .font(.headline)
                            .foregroundStyle(.white)       // white text
                            .frame(maxWidth: .infinity)    // take available space
                    }
                    // Set a fixed size for the button
                    .frame(width: 97, height: 48)
                    // Glass-like effect overlay (a custom modifier you use in your project)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    // Background shape and color that changes if Week is selected
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(goal == .Week  ? .lightOrange : .darkishGray)
                    )

                    // Button 2: Month (same logic as Week, but for Month)
                    Button { goal = goal == .Month ? nil : .Month }  label: {
                        Text("Month")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: 97, height: 48)
                    .glassEffect(.clear.tint(.black.opacity(0.6)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(goal == .Month ? .lightOrange : .darkishGray)
                    )

                    // Button 3: Year (same logic as above, but for Year)
                    Button { goal = goal == .Year  ? nil : .Year  }  label: {
                        Text("Year")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: 97, height: 48)
                    .glassEffect(.clear.tint(.black.opacity(0.6)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(goal == .Year  ? .lightOrange : .darkishGray)
                    )
                }
            }
            // Make this section also fill the width and align left.
            .frame(maxWidth: .infinity, alignment: .leading)

            // Spacer pushes content up, leaving empty space at bottom.
            Spacer()
        }
        // Force this screen to use dark mode colors so it matches your design.
        .preferredColorScheme(.dark)
        // Make the whole screen take up all available space and align its content to the top.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // Add padding on the sides and top to give breathing room.
        .padding(.horizontal, 20)
        .padding(.top, 24)
        // Set the title in the navigation bar at the top of the screen.
        .navigationTitle("Learning Goal")
        // Make the title appear inline (not big and bold).
        .navigationBarTitleDisplayMode(.inline)
        // Add a button to the top-right corner of the navigation bar.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Only show the checkmark button when the user filled the text AND picked a duration.
                if !learningTopic.isEmpty && goal != nil {
                    // The button that saves/updates the goal.
                    Button {
                        // If we are updating in the middle of a running goal, show a warning first.
                        // Otherwise, just go ahead and save (updateGoal()).
                        if isUpdatingMidway { showWarning = true } else { updateGoal() }
                    } label: {
                        // This is the icon that appears in the button.
                        Image(systemName: "checkmark").foregroundColor(.white)
                    }
                    // Make it look like a prominent (filled) button.
                    .buttonStyle(.borderedProminent)
                    // Tint color (your orange) with some transparency.
                    .tint(Color(.richOrange).opacity(0.65))
                }
            }
        }
        // This creates a popup alert when showWarning becomes true.
        .alert("Update Learning goal", isPresented: $showWarning) {
            // Left button: close the alert and do nothing.
            Button("Dismiss", role: .cancel) { }
            // Right button: actually perform the update now.
            Button("Update") { updateGoal() }
        } message: {
            // The text shown inside the alert explaining the consequence.
            Text("If you update now, your streak will start over.")
        }
    }

    // MARK: - MVVM update (via VM)
    // This function tells the ViewModel to update the goal using the user input.
    // We keep the logic in the ViewModel so the View stays simple (that's the MVVM idea).
    private func updateGoal() {
        vm.updateGoal(
            topic: learningTopic,             // What the user typed
            durationLabel: durationLabel,     // "Week" / "Month" / "Year" based on selection
            isUpdatingMidway: isUpdatingMidway, // Should we reset with warning logic?
            date: vm.progress.simulatedDate     // Optional simulated date (often nil in real app)
        )
        // Close this screen after saving.
        dismiss()
    }
}

// This is only for Xcode's preview canvas (so you can see the screen while coding).
#Preview {
    NavigationStack {
        // Create a fake, empty model for preview purposes.
        let p = LearningProgress()
        // Show the screen and inject a temporary ViewModel so preview works.
        LearningGoalView()
            .environmentObject(LearningProgressViewModel(progress: p))
    }
}
