//
//  ToolbarView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

// Import SwiftUI so we can build and style user interfaces.
import SwiftUI

// This struct defines a small reusable component (a toolbar) that appears at the top of your screen.
struct ToolbarView: View {
    // MARK: - Actions passed from parent

    // These are *closures* (tiny functions) that get called when the user taps a button.
    // A closure is just a block of code that can be stored in a variable and called later.

    // `onCalendarTap` will run when the calendar icon is pressed.
    // It has an empty default `{}` so if the parent view doesn't pass any function, it won't crash.
    var onCalendarTap: () -> Void = {}

    // `onPencilTap` will run when the pencil icon is pressed.
    // Same safe default — it does nothing if not provided.
    var onPencilTap: () -> Void = {}

    // MARK: - Body (UI layout)
    var body: some View {
        // HStack = Horizontal Stack → lays out elements from left to right.
        HStack {
            // Text label that says "Activity" on the left side.
            Text("Activity")
                .font(.system(size: 34, weight: .bold)) // Large, bold system font.

            // Spacer pushes everything on its right all the way to the edge.
            Spacer()

            // Custom container you made for the glass effect group (like a transparent frame).
            // The parameter `spacing: 40.0` means there’s 40 points between the two buttons inside it.
            GlassEffectContainer(spacing: 40.0) {

                // FIRST BUTTON: Calendar button
                // When pressed, run the function (closure) that the parent gave us.
                Button { onCalendarTap() } label: {
                    // The visual part of the button (its label)
                    Image(systemName: "calendar")           // Built-in SF Symbol icon.
                        .font(.system(size: 22, weight: .bold)) // Medium-large bold icon.
                        .frame(width: 44, height: 44)           // Circle-like square area.
                        .foregroundStyle(.white)                // White color.
                        .glassEffect()                          // Adds your modern transparent style.
                }

                // SECOND BUTTON: Pencil (edit) button
                // When pressed, call the other closure `onPencilTap()`.
                Button { onPencilTap() } label: {
                    Image(systemName: "pencil.and.outline") // Another SF Symbol.
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                        .glassEffect() // Same shiny glass look.
                }
            }
        }
        // Fix the toolbar’s total frame size (matches your design).
        .frame(width: 393, height: 46)

        // Force this view to always appear in dark mode colors (consistent look).
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
// Lets you see the toolbar instantly in Xcode's canvas while coding.
#Preview {
    ToolbarView() // Uses default empty closures for both buttons.
}
