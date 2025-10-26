//
//  LearningProgress.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//
import SwiftUI

@Observable
class LearningProgress {
    var loggedDates: Set<Date> = []
    var freezedDates: Set<Date> = []  // Track frozen dates
    var currentStreakCount: Int = 0
    var frozenDaysCount: Int = 0
    
    // Goal information
    var learningTopic: String = ""
    var goalDuration: String = "Week"  // Week, Month, or Year
    var goalStartDate: Date = Date()  // Track when goal started
    
    var maxFreezes: Int {
        switch goalDuration {
        case "Week": return 2
        case "Month": return 8
        case "Year": return 96
        default: return 2
        }
    }
    
    // Check if goal is completed
    var isGoalCompleted: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: getCurrentDate())
        let startOfGoal = calendar.startOfDay(for: goalStartDate)
        let daysSinceStart = calendar.dateComponents([.day], from: startOfGoal, to: today).day ?? 0
        
        switch goalDuration {
        case "Week": return daysSinceStart >= 7
        case "Month": return daysSinceStart >= 30
        case "Year": return daysSinceStart >= 365
        default: return false
        }
    }
    
    // Check if user has freezes remaining
    var hasFreezesRemaining: Bool {
        return frozenDaysCount < maxFreezes
    }
    
    var freezesRemaining: Int {
        return max(0, maxFreezes - frozenDaysCount)
    }
    
    // Testing feature - simulate different days
    var simulatedDate: Date? = nil  // Set this to test different dates
    
    private let calendar = Calendar.current
    
    // Get the current date (real or simulated)
    private func getCurrentDate() -> Date {
        return simulatedDate ?? Date()
    }
    
    // Log today as learned
    func logToday() {
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Only log if not already logged or freezed today
        guard !isDateLogged(today) && !isDateFreezed(today) else { return }
        
        loggedDates.insert(today)
        updateStreakCount()
    }
    
    // Log today as freezed
    func freezeToday() {
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Check if user has freezes remaining
        guard hasFreezesRemaining else { return }
        
        // Only freeze if not already logged or freezed today
        guard !isDateLogged(today) && !isDateFreezed(today) else { return }
        
        freezedDates.insert(today)
        updateFreezeCount()
        updateStreakCount()  // Recalculate streak to maintain it
    }
    
    // Check if a specific date is logged
    func isDateLogged(_ date: Date) -> Bool {
        let normalized = calendar.startOfDay(for: date)
        return loggedDates.contains(normalized)
    }
    
    // Check if a specific date is freezed
    func isDateFreezed(_ date: Date) -> Bool {
        let normalized = calendar.startOfDay(for: date)
        return freezedDates.contains(normalized)
    }
    
    // Check if today is logged
    func isTodayLogged() -> Bool {
        return isDateLogged(getCurrentDate())
    }
    
    // Check if today is freezed
    func isTodayFreezed() -> Bool {
        return isDateFreezed(getCurrentDate())
    }
    
    // Get the color for a specific date in the calendar
    func colorForDate(_ date: Date) -> Color? {
        let normalized = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Check freeze first
        if normalized == today && isDateFreezed(today) {
            return .lightBlue  // Today's date when frozen stays light blue
        } else if isDateFreezed(normalized) {
            return .darkishBlue  // Past frozen dates are dark blue
        }
        
        // Then check logged
        if normalized == today && isDateLogged(today) {
            return .lightOrange  // Today's date when logged stays light orange
        } else if isDateLogged(normalized) {
            return .brownie  // Past logged dates are brownie
        }
        
        return nil  // Not logged or frozen
    }
    
    // Get the text color for a specific date (for the day number)
    func textColorForDate(_ date: Date) -> Color {
        let normalized = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Current day (today) always white text
        if normalized == today {
            return .white
        }
        
        // Past frozen dates - light blue text
        if isDateFreezed(normalized) {
            return .lightBlue
        }
        
        // Past logged dates - light orange text
        if isDateLogged(normalized) {
            return .lightOrange
        }
        
        // Default - white text
        return .white
    }
    
    // Update streak count based on logged dates (only from current goal start)
    private func updateStreakCount() {
        var streak = 0
        var currentDate = calendar.startOfDay(for: getCurrentDate())
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Count backwards from today, but ONLY dates on or after goal start
        while currentDate >= goalStart {
            // Check if this date is logged or frozen
            if isDateLogged(currentDate) || isDateFreezed(currentDate) {
                // Only count logged days in the streak (not frozen days)
                if isDateLogged(currentDate) {
                    streak += 1
                }
                // Continue to previous day
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                // Hit a gap - streak is broken, stop counting
                break
            }
        }
        
        currentStreakCount = streak
    }
    
    // Update freeze count based on frozen dates (only from current goal start)
    private func updateFreezeCount() {
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Only count freezes that occurred after goal start date
        frozenDaysCount = freezedDates.filter { date in
            let normalized = calendar.startOfDay(for: date)
            return normalized >= goalStart
        }.count
    }
    
    // Check if streak should be reset (missed yesterday without log or freeze)
    func checkAndResetStreak() -> Bool {
        let today = calendar.startOfDay(for: getCurrentDate())
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Grace period: Don't check if today is within 2 days of goal start
        let daysSinceGoalStart = calendar.dateComponents([.day], from: goalStart, to: today).day ?? 0
        if daysSinceGoalStart <= 1 {
            return false  // Grace period - don't check streak
        }
        
        // If today is already logged or frozen, streak is safe
        if isDateLogged(today) || isDateFreezed(today) {
            return false
        }
        
        // Get yesterday
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return false
        }
        
        // Only check if yesterday is AFTER goal start
        // If yesterday is before or on goal start day, don't break streak
        if yesterday <= goalStart {
            return false
        }
        
        // If yesterday wasn't logged or frozen, streak is broken
        // (This represents more than 32 hours without activity)
        if !isDateLogged(yesterday) && !isDateFreezed(yesterday) {
            return true  // Streak broken - needs reset
        }
        
        return false  // Streak is safe
    }
    
    // Reset the streak (used for repeating same goal - keeps calendar history)
    func resetStreak() {
        // Don't clear loggedDates and freezedDates - keep them for calendar history
        // Only reset the counters
        currentStreakCount = 0
        frozenDaysCount = 0
    }
    
    // Reset for completely new goal midway - KEEPS calendar history, resets counters
    func resetForNewGoal() {
        let today = calendar.startOfDay(for: getCurrentDate())
        
        // Remove today from logged/frozen dates so buttons become active again
        loggedDates.remove(today)
        freezedDates.remove(today)
        
        // Force counters to 0 immediately
        currentStreakCount = 0
        frozenDaysCount = 0
        
        // Note: goalStartDate should already be set by caller (ProgressManager)
        // The counters are now 0 and will stay 0 until user logs again
    }
    
    // Complete reset - clears everything including calendar (only if user wants to delete all data)
    func resetStreakAndHistory() {
        loggedDates.removeAll()
        freezedDates.removeAll()
        currentStreakCount = 0
        frozenDaysCount = 0
    }
    
    // Reset goal while keeping calendar history
    func resetGoalKeepHistory() {
        // Start a new goal cycle - reset counters and start date
        // but keep ALL historical data visible in calendar
        goalStartDate = calendar.startOfDay(for: getCurrentDate())
        currentStreakCount = 0
        frozenDaysCount = 0
        
        // Don't touch loggedDates or freezedDates - they stay for calendar history
        // This allows starting fresh while preserving the visual history
    }
    
    // Reset when learning goal is updated
    func resetForGoalUpdate() {
        // Keep calendar history, just reset counters
        resetStreak()
    }
    
    // MARK: - Testing Helpers
    
    // Move to next day (for testing)
    func advanceToNextDay() {
        if let simulated = simulatedDate {
            simulatedDate = calendar.date(byAdding: .day, value: 1, to: simulated)
        } else {
            simulatedDate = calendar.date(byAdding: .day, value: 1, to: Date())
        }
    }
    
    // Move to previous day (for testing)
    func goToPreviousDay() {
        if let simulated = simulatedDate {
            simulatedDate = calendar.date(byAdding: .day, value: -1, to: simulated)
        } else {
            simulatedDate = calendar.date(byAdding: .day, value: -1, to: Date())
        }
    }
    
    // Reset to real current date
    func resetToRealDate() {
        simulatedDate = nil
    }
}
