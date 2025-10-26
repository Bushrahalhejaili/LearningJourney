//
//  Persistence.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 04/05/1447 AH.
//

import SwiftUI
import Foundation

// Only used inside this file
private struct LearningProgressSnapshot: Codable {
    var loggedDates: [Date]
    var freezedDates: [Date]
    var currentStreakCount: Int
    var frozenDaysCount: Int
    var learningTopic: String
    var goalDuration: String
    var goalStartDate: Date
}

enum Persistence {
    private static let key = "LearningProgress.snapshot.v1"

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Private helpers (signatures reference a private type)
    fileprivate static func snapshot(from p: LearningProgress) -> LearningProgressSnapshot {
        LearningProgressSnapshot(
            loggedDates: Array(p.loggedDates),
            freezedDates: Array(p.freezedDates),
            currentStreakCount: p.currentStreakCount,
            frozenDaysCount: p.frozenDaysCount,
            learningTopic: p.learningTopic,
            goalDuration: p.goalDuration,
            goalStartDate: p.goalStartDate
        )
    }

    fileprivate static func apply(_ s: LearningProgressSnapshot, to p: LearningProgress) {
        p.loggedDates = Set(s.loggedDates)
        p.freezedDates = Set(s.freezedDates)
        p.currentStreakCount = s.currentStreakCount
        p.frozenDaysCount = s.frozenDaysCount
        p.learningTopic = s.learningTopic
        p.goalDuration = s.goalDuration
        p.goalStartDate = s.goalStartDate
    }

    // MARK: - Public API
    static func save(_ p: LearningProgress) {
        let s = snapshot(from: p)
        if let data = try? encoder.encode(s) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> LearningProgress? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? decoder.decode(LearningProgressSnapshot.self, from: data)
        else { return nil }

        let p = LearningProgress()
        apply(snap, to: p)
        return p
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
