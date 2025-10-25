//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//
import SwiftUI

struct ActivityView: View {
    // Create shared progress tracker
    @State private var progress: LearningProgress
    
    init(learningTopic: String, goalDuration: String) {
        // Initialize progress with goal info
        let initialProgress = LearningProgress()
        initialProgress.learningTopic = learningTopic
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
                CalenderProgressView(learningTopic: progress.learningTopic, progress: progress)
                
                // Show goal completed view or log buttons
                if progress.isGoalCompleted {
                    GoalCompletedView()
                } else {
                    LogActionButton(progress: progress)
                }
            }

            Spacer()
            
            // Show new goal button or freeze button
            if progress.isGoalCompleted {
                NewGoalButton(progress: progress)
            } else {
                FreezeButton(progress: progress)
                    .frame(width: 274, height: 48)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)

        // Present calendar
        .navigationDestination(isPresented: $goToCalendar) {
            CalenderPageView(progress: progress)
        }
        // Present learning goal editor
        .navigationDestination(isPresented: $goToLearningGoal) {
            LearningGoalView(progress: progress, isUpdatingMidway: !progress.isGoalCompleted)
                .navigationTitle("Learning Goal")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @State private var goToCalendar: Bool = false
    @State private var goToLearningGoal: Bool = false
}


#Preview {
    NavigationStack {
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
    }
}
