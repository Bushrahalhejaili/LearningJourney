//
//  LearningJourneyApp.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI
// SwiftUI gives us all the tools to build the app's user interface.

// MARK: - Main App Entry Point
// The @main keyword tells Swift: this is where your app starts running.
@main
struct LearningJourneyApp: App {

    // MARK: - Scene Phase (App Lifecycle)
    // SwiftUI gives us "environment values" that describe the app’s current state.
    // scenePhase tells us whether the app is active (in use), inactive, or in the background.
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Load Saved Progress
    // When the app starts, it tries to load saved user progress using Persistence.load().
    // If nothing has been saved yet (for example, first launch), it will be nil.
    // @State allows the view to react if this value changes (for example, after onboarding).
    @State private var bootProgress: LearningProgress? = Persistence.load()

    // MARK: - Body (defines what appears on screen)
    var body: some Scene {
        // Scene = a window or main container of your app (like a tab or main screen).
        WindowGroup {
            // This block decides what the user sees when the app starts.
            // If a saved goal exists → go to the ActivityView directly.
            // Otherwise → show the OnboardingView for goal setup.
            if let existing = bootProgress,
               // ✅ Extra check: only show ActivityView if the saved data looks valid
               !existing.learningTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               ["Week","Month","Year"].contains(existing.goalDuration)
            {
                // Load the ActivityView and inject the user’s existing progress.
                ActivityView(progress: existing)
            } else {
                // Show the onboarding page for first-time setup.
                OnboardingView()
            }
        }

        // MARK: - Handle App Lifecycle Events
        // This code runs every time the app’s scene (window) changes state.
        .onChange(of: scenePhase) { _, newPhase in
            // If the app moves to the background (for example, user minimizes it):
            if newPhase == .background {
                // Try to save current progress (if it exists or can be loaded).
                if let p = bootProgress ?? Persistence.load() {
                    Persistence.save(p)
                }
            }
        }
    }
}
