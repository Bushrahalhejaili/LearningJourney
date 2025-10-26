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

    // ✅ New initializer: boot from saved progress
    init(progress existing: LearningProgress) {
        _progress = State(initialValue: existing)
    }

    // ✅ Original initializer: onboarding entry
    init(learningTopic: String, goalDuration: String) {
        if let loaded = Persistence.load() {
            _progress = State(initialValue: loaded)
        } else {
            let initialProgress = LearningProgress()
            initialProgress.learningTopic = learningTopic
            initialProgress.goalDuration = goalDuration
            _progress = State(initialValue: initialProgress)
        }
    }

    // PERSISTENCE: save when app backgrounds
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            
            // TESTING CONTROLS - Remove this section when done testing
//            DateSimulatorView(progress: progress)
//                .padding(.top, 20)
            // END TESTING CONTROLS

            Spacer()

            // Toolbar navigation
            ToolbarView(
                onCalendarTap: { goToCalendar = true },
                onPencilTap:   { goToLearningGoal = true }
            )

            Spacer()

            VStack(spacing: 32) {
                CalenderProgressView(learningTopic: progress.learningTopic, progress: progress)
                
                if progress.isGoalCompleted {
                    GoalCompletedView()
                } else {
                    LogActionButton(progress: progress)
                }
            }

            Spacer()
            
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

        // -------- PERSISTENCE HOOKS --------
        .onAppear { Persistence.save(progress) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { Persistence.save(progress) }
        }
        .onChange(of: progress.loggedDates) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.freezedDates) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.currentStreakCount) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.frozenDaysCount) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.learningTopic) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.goalDuration) { _, _ in Persistence.save(progress) }
        .onChange(of: progress.goalStartDate) { _, _ in Persistence.save(progress) }
        // ----------------------------------
    }
    
    @State private var goToCalendar: Bool = false
    @State private var goToLearningGoal: Bool = false
}

#Preview {
    NavigationStack {
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
    }
}
