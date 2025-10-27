//
//  Persistence.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 04/05/1447 AH.
//

import SwiftUI
import Foundation

// MARK: - Internal Snapshot Structure
// This struct is a simplified copy of LearningProgress
// It’s Codable, meaning it can be easily converted to JSON for saving and loading.
// We use this instead of LearningProgress directly because LearningProgress
// uses SwiftUI’s @Observable, which is not Codable.
private struct LearningProgressSnapshot: Codable {
    var loggedDates: [Date]
    var freezedDates: [Date]
    var currentStreakCount: Int
    var frozenDaysCount: Int
    var learningTopic: String
    var goalDuration: String
    var goalStartDate: Date
}

// MARK: - Persistence Manager
// Handles all saving, loading, and clearing of user progress from UserDefaults.
// UserDefaults = small, permanent storage for simple user data.
enum Persistence {
    private static let key = "LearningProgress.snapshot.v1" // Unique key to identify saved data.

    // Encoder: Converts Swift objects → JSON (for saving)
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601 // Store dates in standard ISO 8601 format
        return e
    }()

    // Decoder: Converts JSON → Swift objects (for loading)
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Validation Function
    // Ensures saved data is meaningful and not empty.
    // It returns true only if the user actually entered a topic and a valid duration.
    private static func isValid(_ s: LearningProgressSnapshot) -> Bool {
        let hasTopic = !s.learningTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let allowedDurations = ["Week", "Month", "Year"]
        let hasValidDuration = allowedDurations.contains(s.goalDuration)
        return hasTopic && hasValidDuration
    }

    // MARK: - Convert Live Progress → Snapshot
    // This function “takes a photo” of the user’s current progress.
    // It extracts only the basic data (that can be safely saved).
    fileprivate static func snapshot(from p: LearningProgress) -> LearningProgressSnapshot {
        // Here, “p” is the live progress object in memory (LearningProgress).
        // We return a new LearningProgressSnapshot that holds the same info
        // but in a Codable-friendly form.
        return LearningProgressSnapshot(
            // Convert Set<Date> → Array<Date> because Sets are not Codable
            loggedDates: Array(p.loggedDates),
            freezedDates: Array(p.freezedDates),
            // Copy over all numeric and text fields
            currentStreakCount: p.currentStreakCount,
            frozenDaysCount: p.frozenDaysCount,
            learningTopic: p.learningTopic,
            goalDuration: p.goalDuration,
            goalStartDate: p.goalStartDate
        )
    }

    // MARK: - Apply Snapshot → Live Progress
    // This function does the opposite: it “rebuilds” the live model
    // from a previously saved snapshot (loaded from disk).
    fileprivate static func apply(_ s: LearningProgressSnapshot, to p: LearningProgress) {
        // “s” = snapshot (saved data from UserDefaults)
        // “p” = the active LearningProgress object we want to refill

        // Convert Array<Date> back to Set<Date> to match the model’s data type
        p.loggedDates = Set(s.loggedDates)
        p.freezedDates = Set(s.freezedDates)

        // Copy back all the primitive data
        p.currentStreakCount = s.currentStreakCount
        p.frozenDaysCount = s.frozenDaysCount
        p.learningTopic = s.learningTopic
        p.goalDuration = s.goalDuration
        p.goalStartDate = s.goalStartDate

        // Now “p” is fully updated and ready to use in the app again
    }

    // MARK: - Public API

    // SAVE FUNCTION
    // Converts the user’s current progress into a snapshot, encodes it as JSON,
    // and stores it in UserDefaults under our unique key.
    static func save(_ p: LearningProgress) {
        let s = snapshot(from: p)
        // Don’t save if the user hasn’t completed onboarding
        guard isValid(s) else { return }

        if let data = try? encoder.encode(s) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // LOAD FUNCTION
    // Fetches the saved JSON data from UserDefaults,
    // decodes it into a snapshot, and rebuilds a new LearningProgress object.
    static func load() -> LearningProgress? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? decoder.decode(LearningProgressSnapshot.self, from: data)
        else { return nil }

        // Verify that the saved data is valid
        guard isValid(snap) else { return nil }

        // Create a new LearningProgress instance and fill it with saved data
        let p = LearningProgress()
        apply(snap, to: p)
        return p
    }

    // CLEAR FUNCTION
    // Completely removes any saved data from UserDefaults.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
