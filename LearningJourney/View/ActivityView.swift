//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

// Bring in SwiftUI, Apple's UI framework we use to build screens.
import SwiftUI

// This struct defines one screen in your app, called ActivityView.
// It follows the SwiftUI "View" protocol, which means it provides a `body` describing the UI.
struct ActivityView: View {
    // MARK: - State & Dependencies

    // @StateObject creates and owns a ViewModel instance for this screen.
    // "StateObject" means: SwiftUI should keep this object alive as long as this view is alive,
    // and if anything inside the object changes, SwiftUI will redraw the UI.
    // The ViewModel (LearningProgressViewModel) holds the app logic + data (the "brain").
    @StateObject private var vm: LearningProgressViewModel

    // MARK: - Initializers (two ways to create this screen)

    // 1) This init is used when you ALREADY have a saved `LearningProgress` model.
    // For example, when the app launches and loads saved data from disk,
    // we can pass that model here, and create a ViewModel based on it.
    init(progress existing: LearningProgress) {
        // We wrap the new ViewModel in a StateObject so SwiftUI manages its lifetime.
        _vm = StateObject(wrappedValue: LearningProgressViewModel(progress: existing))
    }

    // 2) This init is used if you came from the Onboarding screen.
    // The user just chose a topic + duration, so we create a BRAND NEW model here.
    init(learningTopic: String, goalDuration: String) {
        // Create a fresh model object that holds the user's progress and settings.
        let p = LearningProgress()
        // Save what the user typed and chose on the previous screen.
        p.learningTopic = learningTopic
        p.goalDuration   = goalDuration
        // Start the goal from "today" (midnight). Using startOfDay makes dates easier to compare.
        p.goalStartDate  = Calendar.current.startOfDay(for: Date())
        // Create the ViewModel using this new model.
        _vm = StateObject(wrappedValue: LearningProgressViewModel(progress: p))
        // Save right away so if the app closes, the data is not lost.
        Persistence.save(p) // immediate save like before
    }

    // Reads the app's current "scene phase" from the environment (active / inactive / background).
    // We use this to save when the app goes to background.
    @Environment(\.scenePhase) private var scenePhase

    // These @State variables control whether we should navigate to another screen.
    // When they turn true, the NavigationStack triggers a push to the destination view.
    @State private var goToCalendar: Bool = false
    @State private var goToLearningGoal: Bool = false

    // MARK: - UI Description

    // `body` describes what shows on the screen.
    var body: some View {
        // We move the big UI into a helper called `content` to keep this file easy to read.
        content
            // This runs when the scenePhase changes (e.g., app goes to background).
            .onChange(of: scenePhase) { _, newPhase in
                // If the app is moving to the background (user switches apps or locks phone)...
                if newPhase == .background {
                    // ...save the latest progress to disk so nothing is lost.
                    Persistence.save(vm.progress)
                }
            }
    }

    // MARK: - Content builder
    // `@ViewBuilder` lets us return multiple views inside without wrapping with `AnyView`.
    // We split the large body into this section so the Swift compiler stays happy.
    @ViewBuilder
    private var content: some View {
        // Pull a local reference to the model from the ViewModel.
        // This shortens code (typing `progress` instead of `vm.progress`) and helps the type-checker.
        let progress = vm.progress

        // Vertical stack: puts items from top to bottom.
        VStack {

            // ---------------------------------------------
            // (Optional) TEST CONTROLS for simulating dates
            // You had a DateSimulatorView here while testing.
            // Keeping it commented out makes it easy to bring back later.
            // ---------------------------------------------
            // DateSimulatorView(progress: progress)
            //     .padding(.top, 20)

            // Spacer adds flexible empty space, pushing content away.
            Spacer()

            // Toolbar across the top: shows title + calendar button + edit button.
            // We pass closures (tiny functions) for what happens when each button is tapped.
            ToolbarView(
                onCalendarTap: { goToCalendar = true },   // When calendar icon tapped, set flag to navigate.
                onPencilTap:   { goToLearningGoal = true } // When pencil icon tapped, navigate to goal editor.
            )

            // Another spacer to separate toolbar from the main content area visually.
            Spacer()

            // Group the "progress card" + log button (or "goal completed") together with spacing.
            VStack(spacing: 36) {
                // The weekly progress card UI (month title + week bubbles + counters).
                // It reads data from the shared ViewModel via EnvironmentObject.
                CalendarProgressView()
                    .environmentObject(vm)

                // If the user has completed the goal period (week/month/year), show a celebration view.
                if progress.isGoalCompleted {
                    GoalCompletedView()
                } else {
                    // Otherwise, show the big round log button (Log as Learned / Learned Today).
                    // It also reads/writes via the shared ViewModel.
                    LogActionButton()
                        .environmentObject(vm)
                }
            }

            // Spacer pushes the "new goal" or "freeze" button to the bottom.
            Spacer()

            // Bottom button changes depending on whether the goal is completed.
            if progress.isGoalCompleted {
                // Show "Set new learning goal" button if goal period ended.
                NewGoalButton()
                    .environmentObject(vm)
            } else {
                // Otherwise show "Log as Freezed" button (and its small counter text).
                FreezeButton()
                    .environmentObject(vm)
                    .frame(width: 274, height: 48) // Fixed size for visual consistency.
            }
        }
        // Force dark mode for this screen (so it looks as designed regardless of system theme).
        .preferredColorScheme(.dark)
        // Hide the back button (this is a top-level screen in your flow).
        .navigationBarBackButtonHidden(true)

        // MARK: - Navigation destinations
        // These two blocks define where to navigate when the @State flags turn true.

        // When `goToCalendar` becomes true, push the full calendar page.
        .navigationDestination(isPresented: $goToCalendar) {
            // We pass the *model* (not the ViewModel) so the calendar can read dates & colors.
            CalendarPageView(progress: progress)
        }

        // When `goToLearningGoal` becomes true, push the goal-editing screen.
        .navigationDestination(isPresented: $goToLearningGoal) {
            // Pass a flag telling the editor whether the user is mid-goal (affects warning text).
            LearningGoalView(isUpdatingMidway: !progress.isGoalCompleted)
                // Inject the same ViewModel so edits update the same source of truth.
                .environmentObject(vm)
                // Set the title for the navigation bar at top.
                .navigationTitle("Learning Goal")
                // Make the title centered and not large.
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview support (Xcode canvas)
// This small helper creates a ready-to-use ViewModel for previews,
// so your preview renders with realistic data.
private enum ActivityPreviewSeed {
    // A static (one copy) property that holds a configured ViewModel.
    static let vm: LearningProgressViewModel = {
        // Create a LearningProgress model with fake/sample values.
        let p = LearningProgress()
        p.learningTopic = "Swift" // pretend user is learning Swift
        p.goalDuration  = "Month" // and set goal to a month
        p.goalStartDate = Calendar.current.startOfDay(for: Date()) // starting today
        // Wrap the model in a ViewModel and return it.
        return LearningProgressViewModel(progress: p)
    }()
}

// The #Preview section lets you see the screen inside Xcode’s preview pane.
// It runs only in the editor, not in the real app.
#Preview {
    // NavigationStack is needed because ActivityView uses navigation destinations.
    NavigationStack {
        // Use the initializer that mimics coming from Onboarding.
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
            // Inject the seeded ViewModel so child views using .environmentObject(vm) can find it in the preview.
            .environmentObject(ActivityPreviewSeed.vm)
    }
}
