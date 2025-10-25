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
    
    // Update streak count based on logged dates (only from current goal start)
    private func updateStreakCount() {
        var streak = 0
        var currentDate = calendar.startOfDay(for: getCurrentDate())
        let goalStart = calendar.startOfDay(for: goalStartDate)
        
        // Count backwards from today, including both logged and frozen days
        // But stop at goal start date
        while (isDateLogged(currentDate) || isDateFreezed(currentDate)) && currentDate >= goalStart {
            // Only count logged days in the streak (not frozen days)
            if isDateLogged(currentDate) {
                streak += 1
            }
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
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
    
    // Check if streak should be reset (more than 32 hours since last log)
    func checkAndResetStreak() {
        guard let lastLoggedDate = loggedDates.max() else { return }
        
        let hoursSinceLastLog = calendar.dateComponents([.hour], from: lastLoggedDate, to: getCurrentDate()).hour ?? 0
        
        if hoursSinceLastLog > 32 {
            resetStreak()
        }
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
        // Don't clear loggedDates and freezedDates - preserve ALL history for calendar
        // Only reset the counters so streak starts fresh
        currentStreakCount = 0
        frozenDaysCount = 0
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
