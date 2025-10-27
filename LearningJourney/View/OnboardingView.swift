//
//  ContentView.swift
//  Learning Journey
//
//  Created by Bushra Hatim Alhejaili on 16/10/2025.
//

// SwiftUI is Apple’s modern framework for building app user interfaces (UI).
// It allows you to describe what your screen should look like using simple code blocks.
import SwiftUI

// Every screen or UI component in SwiftUI is called a “View”.
// Here we define a new screen called OnboardingView.
struct OnboardingView: View {

    //MARK: - Stored Variables (the app's memory)

    // The "@" symbol in Swift means this variable is connected to SwiftUI in a special way.
    // @State means: this value belongs to the View, and if it changes, SwiftUI will re-draw the screen automatically.
    // We start with an empty string, meaning the user hasn’t typed anything yet.
    @State private var learningTopic: String = ""

    // An enum is a way to create a list of related options.
    // Here we define 3 possible choices for the user's goal duration.
    enum GoalDuration { case Week, Month, Year }

    // This variable stores which option the user picked.
    // The question mark (?) means it's optional — it might be empty at first.
    @State private var goal: GoalDuration?

    // MARK: - Design Constants (styling values)
    // These are fixed values we use for styling, colors, and sizes.
    // Keeping them as variables makes the design easy to adjust later.

    var textFieldFont: Font = .title3
    var textFieldTextColor: Color = Color(.white)

    var flameSize: CGFloat = 40        // CGFloat is a number type used for layout sizes.
    var flameColor: Color = .orange

    var buttonWidth: CGFloat = 182
    var buttonHeight: CGFloat = 48

    // MARK: - Focus Control for Keyboard
    // This special property tracks whether the keyboard is focused on the text field.
    // It allows us to close the keyboard when the user taps outside.
    @FocusState private var isTopicFocused: Bool

    // MARK: - Computed Properties
    // Computed properties are like "live formulas" — they update automatically when their inputs change.

    // This property checks if both the topic and goal are filled.
    // If true, the "Start Learning" button becomes active.
    private var isStartEnabled: Bool {
        // `.trimmingCharacters` removes spaces from the start and end.
        // `.isEmpty` checks if the text box is blank.
        // `goal != nil` checks if the user selected a duration.
        !learningTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && goal != nil
    }

    // This property converts the user’s selected goal (like .Week) into a text label ("Week").
    private var durationLabel: String {
        switch goal {
        case .Week:  return "Week"
        case .Month: return "Month"
        case .Year:  return "Year"
        case .none:  return ""  // If no goal is chosen yet, return an empty string.
        }
    }

    // MARK: - Body (the visual part of the screen)
    // Every SwiftUI view must have a "body" — this describes what appears on screen.
    var body: some View {

        // NavigationStack allows us to move between screens (like a stack of pages).
        NavigationStack {

            // VStack means “Vertical Stack” — it arranges elements from top to bottom.
            VStack {

                VStack {
                    // ZStack means “Z-axis Stack” — it layers items on top of each other (like Photoshop layers).

                    ZStack {
                        // First layer (background circle)
                        Circle()
                            .fill(Color(.brownishOrange)) // fills the circle with a custom color.
                            .frame(width: 109, height: 109) // sets the size.
                            .zIndex(0) // sets its stacking order at the back.

                        // Second layer (dark overlay with transparency)
                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 109, height: 109)
                            .glassEffect(.clear) // adds a glass reflection effect (iOS visual style).
                            .zIndex(1) // sits above the brown circle.

                        // Third layer (flame icon)
                        Image(systemName: "flame.fill")
                            // SF Symbols are Apple’s built-in icon set.
                            .symbolRenderingMode(.hierarchical)
                            // .resizable allows the image to change size.
                            .resizable()
                            // .scaledToFit keeps proportions correct.
                            .scaledToFit()
                            // sets the icon’s size to our flameSize variable.
                            .frame(width: flameSize, height: flameSize)
                            // sets the icon’s color.
                            .foregroundStyle(flameColor)
                            .zIndex(2) // this layer is on top.
                    }
                    // Adds space above and below the flame logo.
                    .padding(.vertical, 50)

                    // MARK: - Text and Input Fields Section
                    VStack(alignment: .leading, spacing: 21) {

                        // Greeting section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello Learner")
                                .foregroundColor(Color(.white))
                                .font(.largeTitle.bold())
                            // Displays a big greeting title in white.

                            Text("This app will help you learn everyday!")
                                .foregroundColor(Color(.textGray))
                                .font(.headline.bold())
                            // Subheading below the greeting.
                        }
                        // Expands to full width, aligning text to the left.
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // MARK: - Input Section (text field)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I want to learn")
                                .foregroundColor(Color(.white))
                                .font(.title2)
                            // Label above the text box.

                            TextField("Swift", text: $learningTopic)
                                // The first argument ("Swift") is placeholder text.
                                // The `$` means we "bind" the text to our @State variable learningTopic.
                                // Whatever the user types updates that variable automatically.

                                .font(textFieldFont)
                                .foregroundColor(textFieldTextColor)
                                .textInputAutocapitalization(.words)
                                // Capitalizes the first letter of each word.

                                .disableAutocorrection(true)
                                // Stops the iPhone from suggesting spelling corrections.

                                .focused($isTopicFocused)
                                // Connects this text field to the focus tracker we made earlier.
                                // This lets us hide the keyboard when tapping outside.
                        }
                        // Makes the text field take the full width of the screen and align left.
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // MARK: - Goal Duration Buttons
                        VStack(alignment: .leading, spacing: 12) {
                            Text("I want to learn it in a")
                                .foregroundColor(Color(.white))
                                .font(.title2)
                            // Label for this section.

                            HStack {
                                // HStack means “Horizontal Stack” — arranges elements side by side.

                                // WEEK BUTTON
                                Button {
                                    // This code runs when the Week button is tapped.
                                    // If Week was already selected, we unselect it (nil), otherwise we select it.
                                    goal = goal == .Week ? nil : .Week
                                } label: {
                                    // The button’s visible content (the label).
                                    Text("Week")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                // Sets the size of the button.
                                .frame(width: 97, height: 48)
                                // Adds a translucent glass effect background.
                                .glassEffect(.clear.tint(.black.opacity(0.65)))
                                // The button background changes depending on whether it’s selected.
                                .background(
                                    RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                        .fill(goal == .Week ? .lightOrange : .darkishGray)
                                )

                                // MONTH BUTTON
                                Button {
                                    goal = goal == .Month ? nil : .Month
                                } label: {
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

                                // YEAR BUTTON
                                Button {
                                    goal = goal == .Year ? nil : .Year
                                } label: {
                                    Text("Year")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(width: 97, height: 48)
                                .glassEffect(.clear.tint(.black.opacity(0.6)))
                                .background(
                                    RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                        .fill(goal == .Year ? .lightOrange : .darkishGray)
                                )
                            }
                        }
                        // Keep everything left-aligned.
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                    // Spacer pushes everything up, so the button stays near the bottom.

                    // MARK: - Start Learning Button
                    NavigationLink {
                        // A NavigationLink acts like a button that moves to another screen.
                        // When pressed, it takes the user to ActivityView.

                        ActivityView(
                            // We pass two pieces of information to the next screen:
                            learningTopic: learningTopic.trimmingCharacters(in: .whitespacesAndNewlines),
                            // 1️⃣ The text they typed (with spaces removed).
                            goalDuration: durationLabel
                            // 2️⃣ The label of their selected goal ("Week", "Month", or "Year").
                        )
                    } label: {
                        // This section describes how the button looks.

                        Text("Start Learning")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: buttonWidth, height: buttonHeight)
                            .glassEffect(.clear.tint(.black.opacity(0.65)))
                            // Adds a shiny look on top of the button.
                            .background(
                                RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                    // If form is valid, button is orange; otherwise, dark gray.
                                    .fill(isStartEnabled ? Color.lightOrange : Color.darkishGray)
                            )
                    }
                    // Disables the button if topic or goal isn’t filled.
                    .disabled(!isStartEnabled)

                    Spacer().frame(width: 100, height: 23)
                    // Adds a small gap below the button.
                }
            }
            // Makes the whole screen stay in dark mode.
            .preferredColorScheme(.dark)

            // Hides the back arrow since this is the first screen.
            .navigationBarBackButtonHidden(true)

            // MARK: - Keyboard Behavior
            .ignoresSafeArea(.keyboard)
            // This keeps the layout still when the keyboard appears (so things don’t jump up).

            .onTapGesture { isTopicFocused = false }
            // This hides the keyboard when you tap anywhere outside the text field.
        }
    }
}

// MARK: - Preview for the canvas
#Preview {
    OnboardingView()
    // This lets Xcode show this view on the right side of the editor in real time.
    // It’s not part of the app itself — it’s for you, the developer, to see what it looks like.
}
