//
//  LearningJourneyApp.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI

@main
struct LearningJourneyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var bootProgress: LearningProgress? = Persistence.load()

    var body: some Scene {
        WindowGroup {
            if let existing = bootProgress {
                ActivityView(progress: existing)
            } else {
                OnboardingView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background, let p = bootProgress ?? Persistence.load() {
                Persistence.save(p)
            }
        }
    }
}
