//
//  LearningProgressViewModel.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 05/05/1447 AH.
//

// Import the SwiftUI and Combine frameworks.
// SwiftUI is for UI components, Combine is for observing changes (reactive programming).
import SwiftUI
import Combine

// MARK: - ViewModel class
// This class acts as the "middleman" between your views (UI) and your data (model).
// It holds all the logic to update, save, and read the user's progress.
// It follows the MVVM (Model-View-ViewModel) pattern.
final class LearningProgressViewModel: ObservableObject {
    // MARK: - Published property
    // The @Published property wrapper means: whenever 'progress' changes,
    // all SwiftUI views watching this ViewModel will automatically refresh.
    @Published var progress: LearningProgress

    // MARK: - Initializer
    // When this ViewModel is created, it must be given a LearningProgress object.
    // That object holds the user's current goal, streaks, freezes, etc.
    init(progress: LearningProgress) {
        self.progress = progress
    }

    // MARK: - Read-only convenience properties
    // These are shortcuts that simply return information from the 'progress' model.
    // They make it easier for SwiftUI views to access data without digging into 'progress.'
    var learningTopic: String { progress.learningTopic }          // e.g. "Swift"
    var goalDuration: String { progress.goalDuration }            // e.g. "Month"
    var isGoalCompleted: Bool { progress.isGoalCompleted }        // true/false if goal finished
    var hasFreezesRemaining: Bool { progress.hasFreezesRemaining }// true if user can still freeze days
    var freezesRemaining: Int { progress.freezesRemaining }       // number of freezes left
    var maxFreezes: Int { progress.maxFreezes }                   // total freezes allowed per goal
    var currentStreakCount: Int { progress.currentStreakCount }   // how many days learned in a row
    var frozenDaysCount: Int { progress.frozenDaysCount }         // how many frozen days used

    // MARK: - User Actions (these functions are called by your buttons)
    // Each function does three things:
    // 1. Update the model ('progress')
    // 2. Save the changes to disk (Persistence.save)
    // 3. Notify the UI to refresh (objectWillChange.send)

    // Called when user presses "Log as Learned"
    func logToday() {
        progress.logToday()        // update the model to mark today as learned
        Persistence.save(progress) // save the updated data permanently
        objectWillChange.send()    // tell all views to refresh
    }

    // Called when user presses "Log as Freezed"
    func freezeToday() {
        progress.freezeToday()     // mark today as a frozen day
        Persistence.save(progress) // save it
        objectWillChange.send()    // trigger UI refresh
    }

    // Called when user presses "Set same learning goal and duration"
    func resetGoalKeepHistory() {
        progress.resetGoalKeepHistory() // resets goal but keeps old progress records
        Persistence.save(progress)      // save updated progress
        objectWillChange.send()         // refresh the views
    }

    // Called when user creates or updates a goal (from LearningGoalView)
    func updateGoal(topic: String, durationLabel: String, isUpdatingMidway: Bool, date: Date?) {
        // Clean up any extra spaces and update the topic/duration
        progress.learningTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        progress.goalDuration = durationLabel

        // Decide what to reset depending on if this is a mid-goal change
        if isUpdatingMidway {
            progress.resetForNewGoal() // clears streak & progress for a brand-new goal
        } else {
            progress.resetStreak()     // just resets the streak but keeps the calendar history
        }

        // Start the goal from today’s (or simulated) date
        progress.goalStartDate = Calendar.current.startOfDay(for: date ?? Date())

        // Save to permanent storage
        Persistence.save(progress)

        // Let the views know data changed
        objectWillChange.send()
    }

    // MARK: - Calendar helpers
    // These functions help the calendar color its days correctly.

    // Return the color for a specific date (e.g. orange for learned, blue for frozen, gray otherwise)
    func colorForDate(_ date: Date) -> Color? {
        progress.colorForDate(date)
    }

    // Return the text color (e.g. white or dark gray) depending on the date’s status
    func textColorForDate(_ date: Date) -> Color {
        progress.textColorForDate(date)
    }

    // Check if today has already been marked as "learned"
    func isTodayLogged() -> Bool {
        progress.isTodayLogged()
    }

    // Check if today has already been "frozen"
    func isTodayFreezed() -> Bool {
        progress.isTodayFreezed()
    }
}
