//
//  GoalCompletedView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

// Import SwiftUI to build and style the user interface
import SwiftUI

// MARK: - Global styling variables
// These two variables are outside the struct because multiple views
// could use the same size and color if you want consistency across the app.
var clapSize: CGFloat = 55          // Controls how large the "clap" icon is
var clapColor: Color = .lightOrange // Sets the color of the icon to a light orange

// MARK: - Main view
// This view is shown when the user completes a learning goal.
// It displays a congratulatory message and an icon to celebrate success.
struct GoalCompletedView: View {

    // The font weight (how thick the letters look) can be customized when creating this view.
    // Default is bold.
    var fontWeight: Font.Weight = .bold
    
    // MARK: - Body (UI layout)
    var body: some View {

        // VStack arranges its content vertically — one element per line, top to bottom.
        VStack(spacing: 4) { // spacing = small gap between each element inside the VStack
            
            // ------------------------------------------------------------
            // Celebration Icon
            // ------------------------------------------------------------
            Image(systemName: "hands.and.sparkles.fill") // Built-in SF Symbol (hands clapping)
                .symbolRenderingMode(.hierarchical) // Uses multiple color layers automatically for nice depth
                .resizable()                        // Allows you to change its size
                .scaledToFit()                      // Keeps proportions correct when resizing
                .frame(width: clapSize, height: clapSize) // Uses the global size variable
                .foregroundStyle(clapColor)         // Uses the global color variable
            
            // ------------------------------------------------------------
            // First line of text: main congratulation message
            // ------------------------------------------------------------
            Text("Well done!") // Encouraging message when the goal is achieved
                .font(.system(size: 22, weight: fontWeight)) // System font with size 22, bold by default

            // ------------------------------------------------------------
            // Second line of text: sub-message with more details
            // ------------------------------------------------------------
            Text("Goal completed! start learning again or set a new learning goal")
                .font(.custom("SF Pro", size: 18))           // Uses a custom font and size
                .foregroundColor(Color(.gray))               // Light gray color to make it less bold
                .padding()                                   // Adds space around the text
                .multilineTextAlignment(.center)             // Centers the text if it wraps into multiple lines
        }

        // ------------------------------------------------------------
        // Makes sure this view always uses dark mode colors
        // ------------------------------------------------------------
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
// Lets you see this view in Xcode’s canvas without running the app.
#Preview {
    GoalCompletedView()
}
