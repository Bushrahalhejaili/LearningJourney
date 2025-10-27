//
//  CalenderPageView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 24/10/2025.
//

// Bring in SwiftUI so we can build screens (views).
import SwiftUI

// This defines a new screen (View) that shows many months of a calendar.
struct CalendarPageView: View {
    // We receive a "progress" object from outside.
    // It stores which days were learned/frozen and how to color them.
    var progress: LearningProgress

    // We make a Calendar helper using the "gregorian" calendar system.
    // We'll use it to do date math (like adding months).
    private let calendar = Calendar(identifier: .gregorian)

    // This array will hold every first-day-of-month date we want to show.
    private let months: [Date]

    // This is a custom initializer (a function that runs when we create this view).
    // We accept a "progress" value and an optional date range (start → end).
    // By default, it builds a HUGE range: 100 years in the past to 100 years in the future.
    init(progress: LearningProgress,
         from start: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: -100, to: Date())!,   // Calculate date 100 years ago (force unwrap with !)
         to end: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: 100, to: Date())!     // Calculate date 100 years ahead (force unwrap with !)
    ) {
        // Save the incoming progress so we can use it later in the UI.
        self.progress = progress
        // Fill the "months" array by calling our helper function below.
        // It will create one Date per month between "start" and "end".
        self.months = CalendarPageView.buildMonths(from: start, to: end)
    }

    // This helper function builds an array of monthly dates between two dates.
    // It returns [Date], each Date representing the first day of a month.
    private static func buildMonths(from start: Date, to end: Date) -> [Date] {
        // Use a gregorian calendar just like above for consistency.
        let cal = Calendar(identifier: .gregorian)

        // Extract only the year and month parts of "start" to get the first day of that month.
        let startMonth = cal.date(from: cal.dateComponents([.year, .month], from: start))!

        // Do the same for the end date to get its month start.
        let endMonth   = cal.date(from: cal.dateComponents([.year, .month], from: end))!

        // "cursor" will move forward one month at a time when we build the list.
        var cursor = startMonth

        // Empty array that will collect each month date.
        var result: [Date] = []

        // Keep going until we pass the end month.
        while cursor <= endMonth {
            // Add the current month to the list
            result.append(cursor)
            // Move the cursor forward by 1 month (force unwrap is safe here because valid month math)
            cursor = cal.date(byAdding: .month, value: 1, to: cursor)!
        }

        // Return the full list of months.
        return result
    }

    // The body describes what the screen looks like.
    var body: some View {
        // ScrollViewReader lets us programmatically jump to a specific item.
        ScrollViewReader { proxy in
            // A vertical scroll view to scroll through all months.
            ScrollView {
                // LazyVStack creates items only when needed (more memory friendly).
                LazyVStack(spacing: 24) {
                    // For each month in our months array, build a MonthSectionView below.
                    // We use the month Date itself as the ID (unique).
                    ForEach(months, id: \.self) { month in
                        MonthSectionView(month: month, progress: progress)
                            // Add left/right padding so content isn't hugging the edges.
                            .padding(.horizontal, 16)
                            // Give this view an ID so ScrollViewReader can scroll to it later.
                            .id(month)
                    }
                }
                // Add some space at the top and bottom of the whole list.
                .padding(.vertical, 12)
            }
            // This runs when the screen appears.
            .onAppear {
                // Try to find the Date in "months" that matches the current real month.
                if let target = months.first(where: {
                    // isDate(..., toGranularity: .month) checks if two dates are in the same Year+Month.
                    calendar.isDate($0, equalTo: Date(), toGranularity: .month)
                }) {
                    // We want to jump to that month instantly (no animation or fast scrolling).
                    DispatchQueue.main.async {
                        // A Transaction controls how animations run.
                        var t = Transaction()
                        // Turn animations OFF for this scroll action.
                        t.disablesAnimations = true
                        // Apply this transaction to the scrolling action.
                        withTransaction(t) {
                            // Scroll to the target month, align it to the top of the screen.
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
        }
        // Set the navigation bar title at the top.
        .navigationTitle("All activities")
        // Make the title inline (smaller style).
        .navigationBarTitleDisplayMode(.inline)
        // Force dark mode colors to match your design.
        .preferredColorScheme(.dark)
        // Make the background black and ignore safe areas (fill entire screen).
        .background(Color.black.ignoresSafeArea())
    }
}

// This is a smaller view used INSIDE CalendarPageView for each month section.
private struct MonthSectionView: View {
    // Which month are we drawing? (the first day of that month)
    let month: Date
    // We also need progress here to color each day based on learned/frozen.
    var progress: LearningProgress
    
    // Another Calendar helper just for this subview.
    private let cal = Calendar(identifier: .gregorian)

    // This creates a title like "October 2025" for the current month.
    private var headerTitle: String {
        let f = DateFormatter()    // DateFormatter turns Date into text.
        f.locale = .current        // Use user's language/region
        f.dateFormat = "LLLL yyyy" // "LLLL" = full month name, "yyyy" = 4-digit year
        return f.string(from: month)
    }

    // These are the small labels above the calendar ("SUN", "MON", ...).
    private let weekdayHeaders = ["SUN","MON","TUE","WED","THU","FRI","SAT"]

    // This computes all the cells (boxes) for the month grid.
    // Each item is either an actual day (with a number and date) or a blank for alignment.
    private var dayCells: [(day: Int?, date: Date?)] {
        // Find the first day (e.g., 1st) of the month.
        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!

        // Count how many days are in this month (28..31).
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        // Find the weekday for the first day (1=Sun ... 7=Sat).
        let weekdayIndex = cal.component(.weekday, from: firstOfMonth)

        // How many blank cells are before day 1? (So the grid aligns with the weekday headers.)
        let leadingBlanks = weekdayIndex - 1

        // Start an empty list of cells.
        var cells: [(day: Int?, date: Date?)] = []
        
        // Add the blank cells first so the first row lines up correctly.
        for _ in 0..<leadingBlanks {
            cells.append((day: nil, date: nil))
        }
        
        // Now add one cell per real calendar day (1 → daysInMonth).
        for day in 1...daysInMonth {
            // Make a Date for that day number in this month.
            if let date = cal.date(bySetting: .day, value: day, of: firstOfMonth) {
                // Store both the day number and the actual Date.
                cells.append((day: day, date: date))
            }
        }

        // If the total number of cells isn't a multiple of 7, add blanks to complete the last week row.
        let remainder = cells.count % 7
        if remainder != 0 {
            for _ in 0..<(7 - remainder) {
                cells.append((day: nil, date: nil))
            }
        }

        // Return the final grid for this month.
        return cells
    }

    // The UI for one month section.
    var body: some View {
        // Stack everything vertically for this month.
        VStack(alignment: .leading, spacing: 8) {

            // The month title, like "October 2025".
            Text(headerTitle)
                .font(.system(size: 17, weight: .semibold)) // Slightly larger and bolder.
                .foregroundStyle(.white)                    // White text
                .padding(.top, 4)                           // A little space above

            // The row of weekday labels: SUN, MON, ...
            HStack(spacing: 19) {
                // Loop through each label and draw it.
                ForEach(weekdayHeaders, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 13, weight: .semibold)) // Small bold text
                        .foregroundStyle(.gray)                     // Gray color
                        .frame(maxWidth: .infinity, alignment: .center) // Spread evenly
                }
            }

            // The grid of days (7 columns, as in a real calendar).
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 10
            ) {
                // Enumerate so each cell has a unique index (offset).
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    // ZStack lets us put text on top of a circle color if needed.
                    ZStack {
                        // If this cell is a *real* day (not a blank).
                        if let day = cell.day, let date = cell.date {
                            // Ask "progress" what color this date should be (based on learned/frozen).
                            if let color = progress.colorForDate(date) {
                                // If there is a color, draw a circle (filled) behind the number.
                                Circle()
                                    .fill(color)
                                    .frame(width: 38, height: 38)
                                
                                // Draw the day number on top, with the right text color.
                                Text("\(day)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(progress.textColorForDate(date))
                            } else {
                                // If no color (no progress that day), just show the day number in white.
                                Text("\(day)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                            }
                        } else {
                            // If it's a blank cell (for alignment), show an empty spacer text.
                            Text(" ")
                                .frame(maxWidth: .infinity, minHeight: 32)
                        }
                    }
                    // Make each cell at least this tall.
                    .frame(height: 32)
                }
            }

            // A subtle line separator after each month.
            Divider()
                .background(Color.gray.opacity(0.9))
                .padding(.top, 6)
        }
    }
}

// Preview lets you see this view in Xcode’s canvas without running the app.
#Preview {
    NavigationStack {
        // Create a temporary, empty progress object just for the preview.
        CalendarPageView(progress: LearningProgress())
    }
}
