//
//  CalenderProgressView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

// We import SwiftUI so we can build the screen (views, text, buttons, stacks, etc.)
import SwiftUI

// MARK: - CalendarProgressView
// This view shows a small weekly calendar + your learning stats (streak and freezes).
// It reads data from the ViewModel (vm) using @EnvironmentObject.
struct CalendarProgressView: View {
    // We read the shared ViewModel that was injected by a parent view (.environmentObject(vm)).
    // Think of this like "the one place that knows the current progress and saves it".
    @EnvironmentObject private var vm: LearningProgressViewModel

    // The week we’re currently showing is anchored by this date.
    // If this changes, the week shown on screen changes too.
    @State private var anchorDate: Date = Date()

    // Controls whether the month/year picker popover is open.
    @State private var showingMonthYearPicker = false

    // Which month/year the user picked in the popover wheels.
    // We prefill with "this month" and "this year".
    @State private var pickedMonth: Int = Calendar.current.component(.month, from: Date()) - 1 // 0..11
    @State private var pickedYear: Int  = Calendar.current.component(.year, from: Date())

    // MARK: - Derived values (computed properties)

    // This turns anchorDate into human text like "October 2025".
    private var monthTitle: String {
        let f = DateFormatter()     // A helper to turn dates into text
        f.locale = .current         // Use the user's language/region preferences
        f.dateFormat = "LLLL yyyy"  // "LLLL" = full month name, "yyyy" = 4-digit year
        return f.string(from: anchorDate)
    }

    // Build the 7 dates for the current week (Sunday → Saturday) based on anchorDate.
    private var weekDates: [Date] {
        let cal = Calendar(identifier: .gregorian)  // Use the normal Gregorian calendar
        let weekday = cal.component(.weekday, from: anchorDate) // 1..7 (1 = Sunday)
        // Find the start of the week by going back (weekday - 1) days from anchorDate's startOfDay.
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: anchorDate))!
        // Make 7 days: startOfWeek + 0, +1, +2, ... +6 days
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    // If the "current date" (real or simulated from the ViewModel) has moved beyond the last
    // day shown in the week, we should slide the calendar forward automatically.
    private var shouldAutoAdvance: Bool {
        let cal = Calendar.current
        let currentDate = cal.startOfDay(for: vm.progress.simulatedDate ?? Date()) // simulated or real "today"
        let weekEnd = weekDates.last!  // the Saturday of the displayed week
        return currentDate > weekEnd   // if "today" is after the week on screen, we need to advance
    }

    // Sizes/colors used in the small stat cards.
    var flameSize: CGFloat = 44
    var flameColor: Color = .lightOrange
    var cubeSize: CGFloat = 44
    var cubeColor: Color = .lightBlue

    // MARK: - Body (the actual UI)
    var body: some View {
        // A custom glass-style container you already use in your design system.
        GlassEffectContainer {
            // Stack everything vertically with spacing
            VStack(spacing: 20) {

                // ----------------------------------------------------------
                // Row: Month title + picker toggle + week navigation arrows
                // ----------------------------------------------------------
                HStack {
                    // Show the "October 2025" style label
                    Text(monthTitle)
                        .font(.system(size: 17, weight: .semibold))

                    // Button that opens the month/year picker
                    Button {
                        // When opening, pre-fill the pickers with the current anchor's month/year
                        let comps = Calendar.current.dateComponents([.year, .month], from: anchorDate)
                        pickedMonth = (comps.month ?? 1) - 1 // convert 1..12 to 0..11 for the wheel
                        pickedYear  = comps.year ?? pickedYear
                        // Show the popover
                        showingMonthYearPicker = true
                    } label: {
                        // Chevron flips down/up depending on whether popover is open
                        Image(systemName: showingMonthYearPicker ? "chevron.down" : "chevron.right")
                            .foregroundColor(.orange)
                            .bold()
                    }
                    // The popover content is our month/year wheels
                    .popover(isPresented: $showingMonthYearPicker, arrowEdge: .top) {
                        VStack(spacing: 16) {
                            HStack(spacing: 0) {
                                // Month wheel (0..11)
                                Picker("Month", selection: $pickedMonth) {
                                    // Get localized month names ("January", "February", ...)
                                    let months = DateFormatter().monthSymbols ?? []
                                    // Make a row for each month name
                                    ForEach(Array(months.enumerated()), id: \.offset) { index, name in
                                        Text(name).tag(index) // tag links row to selection value
                                    }
                                }
                                .pickerStyle(.wheel)      // iOS-style spinning wheel
                                .frame(maxWidth: .infinity)

                                // Year wheel (a big range so you can go back/forward)
                                let currentYear = Calendar.current.component(.year, from: Date())
                                Picker("Year", selection: $pickedYear) {
                                    ForEach(1900...(currentYear + 50), id: \.self) { year in
                                        Text(String(year)).tag(year)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                            }
                            .labelsHidden() // hides the word "Month"/"Year" above the wheels

                            // When either wheel changes, apply the new month/year to the anchorDate
                            .onChange(of: pickedMonth) { _, _ in applyPickedMonthYear() }
                            .onChange(of: pickedYear)  { _, _ in applyPickedMonthYear() }
                        }
                        .presentationCompactAdaptation(.popover) // keep as popover on iPhone
                        .padding()
                    }

                    Spacer() // pushes the chevrons to the far right

                    // Back one week button
                    Button {
                        // Smoothly animate the week shift
                        withAnimation(.easeInOut) {
                            anchorDate = shiftWeek(by: -1) // go to previous week
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.orange)
                            .bold()
                    }
                    .padding(.trailing)

                    // Forward one week button
                    Button {
                        withAnimation(.easeInOut) {
                            anchorDate = shiftWeek(by: 1) // go to next week
                        }
                    } label: {
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.orange)
                            .bold()
                    }
                }

                // ----------------------------------------------------------
                // Week row: day names + 7 day circles with colors/numbers
                // ----------------------------------------------------------
                VStack {
                    // Day names row (SUN..SAT)
                    HStack(spacing: 17) {
                        ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        }
                    }

                    // Day circles row (7 items for the current week)
                    HStack {
                        ForEach(weekDates, id: \.self) { date in
                            ZStack {
                                // Circle background:
                                // Use the VM to choose a color (logged = orange/brown, frozen = blue, else idle)
                                Circle()
                                    .fill(vm.colorForDate(date) ?? Color("IdleCircle"))
                                // Day number (e.g., "14")
                                Text(dayNumber(from: date))
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(vm.textColorForDate(date)) // VM also picks the text color
                            }
                            .frame(width: 36, height: 36) // circle size
                            .frame(maxWidth: .infinity)   // spread evenly across the row
                        }
                    }
                }

                // Draw a thin separator line
                Divider()

                // ----------------------------------------------------------
                // Stat cards: "Days Learned" and "Days Freezed"
                // ----------------------------------------------------------
                VStack(spacing: 12) {
                    // "Learning Swift" (or whatever topic the user picked)
                    Text("Learning \(vm.learningTopic)")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        // Card 1: Days Learned (streak count)
                        HStack {
                            // Flame icon
                            Image(systemName: "flame.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                                .frame(width: flameSize, height: flameSize)
                                .foregroundStyle(flameColor)
                            // Numbers/text
                            VStack(alignment:.leading) {
                                Text("\(vm.currentStreakCount)")           // e.g., "5"
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                Text(vm.currentStreakCount == 1 ? "Day Learned" : "Days Learned")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        }
                        .frame(width: 160, height: 69)         // Card size
                        .background(Color(.brownie))           // Card background color
                        .cornerRadius(50)                      // Rounded pill shape
                        .glassEffect(.clear.tint(.darkishBlue))// Your custom glass effect

                        // Card 2: Days Freezed (how many freeze days used in this goal)
                        HStack {
                            // Cube icon
                            Image(systemName: "cube.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                                .frame(width: cubeSize, height: cubeSize)
                                .foregroundStyle(cubeColor)
                            // Numbers/text
                            VStack(alignment:.leading) {
                                Text("\(vm.frozenDaysCount)") // e.g., "2"
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                Text(vm.frozenDaysCount == 1 ? "Day Freezed" : "Days Freezed")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        }
                        .frame(width: 160, height: 69)
                        .background(Color(.darkishBlue))
                        .cornerRadius(50)
                    }
                }
            }
            // Visual polish for the whole container
            .preferredColorScheme(.dark)                      // Force dark mode look
            .cornerRadius(13)                                 // Rounded edges
            .padding()                                        // Outer spacing
            .glassEffect(.clear, in: .rect(cornerRadius: 13)) // Glass look inside rounded rect
            .frame(width: 365, height: 254)                   // Fixed size so it looks consistent
        }
        // If the numbers change (streak or freezes), auto-advance the week if needed.
        .onChange(of: vm.currentStreakCount) { _, _ in checkAndAdvanceWeek() }
        .onChange(of: vm.frozenDaysCount) { _, _ in checkAndAdvanceWeek() }
    }

    // MARK: - Helpers

    // If today moved past the week we're showing, jump the anchorDate forward to keep up.
    private func checkAndAdvanceWeek() {
        if shouldAutoAdvance {
            let cal = Calendar.current
            // Use the simulated date if set; otherwise use real today.
            let currentDate = cal.startOfDay(for: vm.progress.simulatedDate ?? Date())
            // Smooth animation to the new week (the week that contains currentDate)
            withAnimation(.easeInOut) {
                anchorDate = currentDate
            }
        }
    }

    // Move the anchorDate forward/backward by full weeks (7 days each).
    private func shiftWeek(by offset: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: offset * 7, to: anchorDate)!
    }

    // Convert a Date → day number string (e.g., 14).
    private func dayNumber(from date: Date) -> String {
        String(Calendar(identifier: .gregorian).component(.day, from: date))
    }

    // When user picks a month/year from the popover, build a date for the 1st of that month/year
    // and use that as the new anchorDate (the week row will update accordingly).
    private func applyPickedMonthYear() {
        var comps = DateComponents()
        comps.year  = pickedYear
        comps.month = pickedMonth + 1 // convert 0..11 back to 1..12
        comps.day   = 1               // pick the first day of the month
        if let composed = Calendar.current.date(from: comps) {
            anchorDate = composed
        }
    }
}
