//
//  CalenderPageView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 24/10/2025.
//

import SwiftUI

struct CalenderPageView: View {
    var progress: LearningProgress

    // Generate a large continuous range of months (100 years backward & forward)
    private let calendar = Calendar(identifier: .gregorian)
    private let months: [Date]

    init(progress: LearningProgress,
         from start: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: -100, to: Date())!,   // 100 years back
         to end: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: 100, to: Date())!     // 100 years forward
    ) {
        self.progress = progress
        self.months = CalenderPageView.buildMonths(from: start, to: end)
    }

    private static func buildMonths(from start: Date, to end: Date) -> [Date] {
        let cal = Calendar(identifier: .gregorian)
        let startMonth = cal.date(from: cal.dateComponents([.year, .month], from: start))!
        let endMonth = cal.date(from: cal.dateComponents([.year, .month], from: end))!
        var cursor = startMonth
        var result: [Date] = []
        while cursor <= endMonth {
            result.append(cursor)
            cursor = cal.date(byAdding: .month, value: 1, to: cursor)!
        }
        return result
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(months, id: \.self) { month in
                        MonthSectionView(month: month, progress: progress)
                            .padding(.horizontal, 16)
                            .id(month)
                    }
                }
                .padding(.vertical, 12)
            }
            .onAppear {
                if let target = months.first(where: {
                    calendar.isDate($0, equalTo: Date(), toGranularity: .month)
                }) {
                    // Jump instantly (no animation) so there's no fast scrolling effect.
                    DispatchQueue.main.async {
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("All activities")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
    }
}

private struct MonthSectionView: View {
    let month: Date
    var progress: LearningProgress
    
    private let cal = Calendar(identifier: .gregorian)

    private var headerTitle: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "LLLL yyyy"   // "October 2025"
        return f.string(from: month)
    }

    private let weekdayHeaders = ["SUN","MON","TUE","WED","THU","FRI","SAT"]

    private var dayCells: [(day: Int?, date: Date?)] {
        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count
        let weekdayIndex = cal.component(.weekday, from: firstOfMonth) // 1 = Sun ... 7 = Sat
        let leadingBlanks = weekdayIndex - 1

        var cells: [(day: Int?, date: Date?)] = []
        
        // Add leading blank cells
        for _ in 0..<leadingBlanks {
            cells.append((day: nil, date: nil))
        }
        
        // Add actual day cells
        for day in 1...daysInMonth {
            if let date = cal.date(bySetting: .day, value: day, of: firstOfMonth) {
                cells.append((day: day, date: date))
            }
        }

        // pad to complete last week row so grid stays even
        let remainder = cells.count % 7
        if remainder != 0 {
            for _ in 0..<(7 - remainder) {
                cells.append((day: nil, date: nil))
            }
        }
        return cells
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(headerTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.top, 4)

            HStack(spacing: 19) {
                ForEach(weekdayHeaders, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    ZStack {
                        if let day = cell.day, let date = cell.date {
                            // Show circle with color if date has progress
                            if let color = progress.colorForDate(date) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                
                                Text("\(day)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                            } else {
                                // No progress on this date
                                Text("\(day)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                            }
                        } else {
                            Text(" ")
                                .frame(maxWidth: .infinity, minHeight: 32)
                        }
                    }
                    .frame(height: 32)
                }
            }

            Divider()
                .background(Color.gray.opacity(0.9))
                .padding(.top, 6)
        }
    }
}

#Preview {
    NavigationStack {
        CalenderPageView(progress: LearningProgress())
    }
}
