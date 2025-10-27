//
//  LearningProgress.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

// We import SwiftUI because we use Color in this file (for calendar colors).
import SwiftUI 

// @Observable is a Swift macro that makes this class automatically notify SwiftUI
// when its properties change. That means views can react to changes without extra work.
@Observable
class LearningProgress {
    // A Set of Date values to remember which days were "learned".
    // Set means each date is unique (no duplicates).
    var loggedDates: Set<Date> = []
    
    // A Set of Date values to remember which days were "frozen" (used a freeze).
    var freezedDates: Set<Date> = []  // Track frozen dates
    
    // How many days in a row the user has learned (only counting learned days, not frozen).
    var currentStreakCount: Int = 0
    
    // How many frozen days the user has used in the current goal period.
    var frozenDaysCount: Int = 0
    
    // MARK: - Goal information
    
    // The topic the user wants to learn (e.g., "Swift").
    var learningTopic: String = ""
    
    // The length of the goal: "Week", "Month", or "Year".
    var goalDuration: String = "Week"  // Week, Month, or Year
    
    // The date when the current goal started. Used to decide which days count for this goal.
    var goalStartDate: Date = Date()  // Track when goal started
    
    // The maximum number of freezes allowed, depending on the goalDuration.
    // This is a computed property: it calculates a value every time you read it.
    var maxFreezes: Int {
        switch goalDuration {
        case "Week": return 2   // If goal is a week, allow 2 freezes.
        case "Month": return 8  // For a month, allow 8 freezes.
        case "Year": return 96  // For a year, allow 96 freezes.
        default: return 2       // Default fallback.
        }
    }
    
    // MARK: - Derived state (computed from other data)
    
    // This computed property checks whether the goal period is over.
    // It compares today's date with the goal start date and sees how many days passed.
    var isGoalCompleted: Bool {
        let calendar = Calendar.current
        
        // We only care about the "day" part (remove time like 10:34 AM).
        let today = calendar.startOfDay(for: getCurrentDate())
        let startOfGoal = calendar.startOfDay(for: goalStartDate)
        
        // How many whole days from the start to today?
        let daysSinceStart = calendar
            .dateComponents([.day], from: startOfGoal, to: today)
            .day ?? 0
        
        // If enough days passed, the goal is considered completed.
        switch goalDuration {
        case "Week":  return daysSinceStart >= 7
        case "Month": return daysSinceStart >= 30
        case "Year":  return daysSinceStart >= 365
        default:      return false
        }
    }
    
    // True if the user still has freezes left to use.
    var hasFreezesRemaining: Bool {
        return frozenDaysCount < maxFreezes
    }
    
    // How many freezes are left (never go below 0).
    var freezesRemaining: Int {
        return max(0, maxFreezes - frozenDaysCount)
    }
    
    // MARK: - Testing helper
    
    // This is optional. If set, we pretend "today" is this date (handy for testing).
    // If nil, we use the real device date.
    var simulatedDate: Date? = nil  // Set this to test different dates
    
    // We keep a reference to the user's current calendar (for date math).
    private let calendar = Calendar.current
    
    // Returns "now", but if simulatedDate is set (for testing), it returns that instead.
    private func getCurrentDate() -> Date {
        return simulatedDate ?? Date()
    }
    
    // MARK: - User actions that change data
    
    // Mark "today" as learned.
    func logToday() {
        // Normalize to the start of day so time doesn’t matter (only the date).
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Only log if today isn’t already logged or frozen (avoid duplicates).
        guard !isDateLogged(today) && !isDateFreezed(today) else { return }
        
        // Add today to the set of learned dates.
        loggedDates.insert(today)
        
        // Recalculate the streak (because it might increase).
        updateStreakCount()
    }
    
    // Mark "today" as frozen (uses up one freeze, preserves streak boundaries).
    func freezeToday() {
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Don't allow freeze if there are none left.
        guard hasFreezesRemaining else { return }
        
        // Only freeze if today isn’t already learned or frozen.
        guard !isDateLogged(today) && !isDateFreezed(today) else { return }
        
        // Add today to the set of frozen dates.
        freezedDates.insert(today)
        
        // Update how many frozen days are used within this goal.
        updateFreezeCount()
        
        // Recalculate the streak so that logic stays consistent (frozen days aren't counted but may keep continuity).
        updateStreakCount()  // Recalculate streak to maintain it
    }
    
    // MARK: - Query helpers (ask questions about dates)
    
    // Returns true if a specific date is logged as learned.
    func isDateLogged(_ date: Date) -> Bool {
        // Normalize the date to remove time; we only compare by day.
        let normalized = calendar.startOfDay(for: date)
        return loggedDates.contains(normalized)
    }
    
    // Returns true if a specific date is frozen.
    func isDateFreezed(_ date: Date) -> Bool {
        let normalized = calendar.startOfDay(for: date)
        return freezedDates.contains(normalized)
    }
    
    // Convenience: is "today" logged?
    func isTodayLogged() -> Bool {
        return isDateLogged(getCurrentDate())
    }
    
    // Convenience: is "today" frozen?
    func isTodayFreezed() -> Bool {
        return isDateFreezed(getCurrentDate())
    }
    
    // MARK: - Calendar coloring (for the UI)
    
    // Decide what background color a calendar day should be, based on its state.
    func colorForDate(_ date: Date) -> Color? {
        let normalized = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // First: check freezes (frozen days use blue shades).
        if normalized == today && isDateFreezed(today) {
            return .lightBlue  // Today and frozen → light blue
        } else if isDateFreezed(normalized) {
            return .darkishBlue  // Past frozen days → darker blue
        }
        
        // Next: check learned (learned days use orange/brown shades).
        if normalized == today && isDateLogged(today) {
            return .lightOrange  // Today and learned → light orange
        } else if isDateLogged(normalized) {
            return .brownie  // Past learned days → brownie color
        }
        
        // If neither frozen nor learned, return nil (no colored circle).
        return nil
    }
    
    // Decide what text color (numbers inside the calendar circles) to use.
    func textColorForDate(_ date: Date) -> Color {
        let normalized = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Today’s day number should always be visible → white.
        if normalized == today {
            return .white
        }
        
        // Past frozen days → light blue text.
        if isDateFreezed(normalized) {
            return .lightBlue
        }
        
        // Past learned days → light orange text.
        if isDateLogged(normalized) {
            return .lightOrange
        }
        
        // Default for other days.
        return .white
    }
    
    // MARK: - Internal counters (streaks and freezes)
    
    // Recalculate how many days in a row the user has learned.
    // We count backwards from today until we find a gap (a day that is neither learned nor frozen).
    // Only LEARNED days increment the streak number, but frozen days let the “chain” continue.
    private func updateStreakCount() {
        var streak = 0
        
        // Start from today (normalized).
        var currentDate = calendar.startOfDay(for: getCurrentDate())
        
        // Only count dates from the goal start date forward.
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Walk backwards day by day until we go past the goal start.
        while currentDate >= goalStart {
            // If this day is either learned or frozen, the chain is intact.
            if isDateLogged(currentDate) || isDateFreezed(currentDate) {
                // Only learned days increase the numeric streak count.
                if isDateLogged(currentDate) {
                    streak += 1
                }
                // Move to the previous day.
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                // We found a gap → stop counting.
                break
            }
        }
        
        // Store the result so the UI can show it.
        currentStreakCount = streak
    }
    
    // Recalculate how many frozen days were used in THIS goal period.
    private func updateFreezeCount() {
        // Only count frozen dates on or after the goalStartDate.
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Filter the set to only include relevant days, then count them.
        frozenDaysCount = freezedDates.filter { date in
            let normalized = calendar.startOfDay(for: date)
            return normalized >= goalStart
        }.count
    }
    
    // MARK: - Streak safety check
    
    // This checks if the streak should be considered "broken" (missed yesterday without a log or freeze).
    // It returns true if streak is broken and should reset (your ViewModel decides what to do with that info).
    func checkAndResetStreak() -> Bool {
        let today = calendar.startOfDay(for: getCurrentDate())
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Grace period: the first 2 days after starting a goal, do not break the streak automatically.
        let daysSinceGoalStart = calendar
            .dateComponents([.day], from: goalStart, to: today)
            .day ?? 0
        if daysSinceGoalStart <= 1 {
            return false  // Too early to break the streak.
        }
        
        // If today is already learned or frozen, then the streak is safe.
        if isDateLogged(today) || isDateFreezed(today) {
            return false
        }
        
        // Look at "yesterday".
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return false
        }
        
        // If yesterday is before or equal to the start date, don't break the streak.
        if yesterday <= goalStart {
            return false
        }
        
        // If yesterday was neither learned nor frozen, then the chain is broken.
        // (Dev note: Your comment mentions “32 hours,” but here we use calendar days.)
        if !isDateLogged(yesterday) && !isDateFreezed(yesterday) {
            return true  // Streak broken
        }
        
        // Otherwise, streak is okay.
        return false
    }
    
    // MARK: - Reset helpers (different levels)
    
    // Reset only the counters (streak & freezes), keep the calendar history (dates) intact.
    func resetStreak() {
        // Keep loggedDates and freezedDates for the history display.
        currentStreakCount = 0
        frozenDaysCount = 0
    }
    
    // Reset for a totally new goal mid-way.
    // We remove today from logs/freezes so the user can choose again, and reset counters.
    func resetForNewGoal() {
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Remove today's status so buttons become active again for the new goal.
        loggedDates.remove(today)
        freezedDates.remove(today)
        
        // Reset counters immediately.
        currentStreakCount = 0
        frozenDaysCount = 0
        
        // Note: goalStartDate should be set by the caller (ViewModel) for the new goal.
    }
    
    // Full reset: clear all history and counters (use with caution).
    func resetStreakAndHistory() {
        loggedDates.removeAll()
        freezedDates.removeAll()
        currentStreakCount = 0
        frozenDaysCount = 0
    }
    
    // Start a fresh goal cycle BUT keep all calendar history visible.
    // Only reset the counters and set a new start date to "today".
    func resetGoalKeepHistory() {
        goalStartDate = calendar.startOfDay(for: getCurrentDate()) // new cycle starts now
        currentStreakCount = 0
        frozenDaysCount = 0
        // Do not touch loggedDates/freezedDates → history remains.
    }
    
    // When a learning goal is updated (but not scrapped), just reset counters.
    func resetForGoalUpdate() {
        resetStreak()
    }
    
    // MARK: - Testing helpers (simulate time travel)
    
    // Pretend we moved one day into the future.
    func advanceToNextDay() {
        if let simulated = simulatedDate {
            // If already simulating, add 1 day to the simulated date.
            simulatedDate = calendar.date(byAdding: .day, value: 1, to: simulated)
        } else {
            // If not simulating, start from real today + 1.
            simulatedDate = calendar.date(byAdding: .day, value: 1, to: Date())
        }
    }
    
    // Pretend we moved one day into the past.
    func goToPreviousDay() {
        if let simulated = simulatedDate {
            simulatedDate = calendar.date(byAdding: .day, value: -1, to: simulated)
        } else {
            simulatedDate = calendar.date(byAdding: .day, value: -1, to: Date())
        }
    }
    
    // Stop simulating and return to the real current date.
    func resetToRealDate() {
        simulatedDate = nil
    }
}
