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
    @State private var goToLearningGoal: Bool = false
    
    // Create shared progress tracker
    @State private var progress: LearningProgress
    
    init(learningTopic: String, goalDuration: String) {
        self.learningTopic = learningTopic
        self.goalDuration = goalDuration
        
        // Initialize progress with goal duration
        let initialProgress = LearningProgress()
        initialProgress.goalDuration = goalDuration
        _progress = State(initialValue: initialProgress)
    }

    var body: some View {
        VStack {
            // TESTING CONTROLS - Remove this section when done testing
            DateSimulatorView(progress: progress)
                .padding(.top, 20)
            // END TESTING CONTROLS
            
            Spacer()

            // Tell the toolbar how to trigger navigation
            ToolbarView(
                onCalendarTap: { goToCalendar = true },
                onPencilTap:   { goToLearningGoal = true }
            )

            Spacer()

            VStack(spacing: 44) {
                CalenderProgressView(learningTopic: learningTopic, progress: progress)
                LogActionButton(progress: progress)
            }

            Spacer()
            FreezeButton(progress: progress)
                .frame(width: 274, height: 48)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Check for streak reset when view appears
            progress.checkAndResetStreak()
        }

        // Present calendar
        .navigationDestination(isPresented: $goToCalendar) {
            CalenderPageView(progress: progress)
        }
        // Present learning goal editor
        .navigationDestination(isPresented: $goToLearningGoal) {
            LearningGoalView()
                .navigationTitle("Learning Goal")
                .navigationBarTitleDisplayMode(.inline)
                .onDisappear {
                    // Reset streak when returning from learning goal update
                    // You can add a flag to check if goal was actually updated
                    // For now, this will reset on any return from LearningGoalView
                }
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
    }
}
