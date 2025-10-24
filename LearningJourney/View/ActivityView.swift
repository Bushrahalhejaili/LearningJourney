//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//
import SwiftUI

struct ActivityView: View {
    // receive values from Onboarding
    var learningTopic: String
    var goalDuration: String   // kept for future use (e.g., summary text)

    @State private var goToCalendar: Bool = false
    @State private var goToLearningGoal: Bool = false   // ← new

    var body: some View {
        VStack {
            Spacer()

            // Tell the toolbar how to trigger navigation
            ToolbarView(
                onCalendarTap: { goToCalendar = true },
                onPencilTap:   { goToLearningGoal = true }   // ← new
            )

            Spacer()

            VStack(spacing: 44) {
                CalenderProgressView(learningTopic: learningTopic)
                LogActionButton()
            }

            Spacer()
            FreezeButton()
                .frame(width: 274, height: 48)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)

        // Present calendar
        .navigationDestination(isPresented: $goToCalendar) {
            CalenderPageView()
        }
        // Present learning goal editor
        .navigationDestination(isPresented: $goToLearningGoal) {
            LearningGoalView()
                .navigationTitle("Learning Goal")            // header title
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
    }
}
