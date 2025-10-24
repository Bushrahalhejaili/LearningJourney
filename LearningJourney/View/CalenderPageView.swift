//
//  CalenderPageView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 24/10/2025.
//

import SwiftUI

struct CalenderPageView: View {

    // Generate a large continuous range of months (100 years backward & forward)
    private let calendar = Calendar(identifier: .gregorian)
    private let months: [Date]

    init(
        from start: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: -100, to: Date())!,   // 100 years back
        to end: Date = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: 100, to: Date())!     // 100 years forward
    ) {
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
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(months, id: \.self) { month in
                    MonthSectionView(month: month)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .navigationTitle("All activities")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
    }
}

private struct MonthSectionView: View {
    let month: Date
    private let cal = Calendar(identifier: .gregorian)

    private var headerTitle: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "LLLL yyyy"   // "October 2025"
        return f.string(from: month)
    }

    private let weekdayHeaders = ["SUN","MON","TUE","WED","THU","FRI","SAT"]

    private var dayCells: [Int?] {
        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count
        let weekdayIndex = cal.component(.weekday, from: firstOfMonth) // 1 = Sun ... 7 = Sat
        let leadingBlanks = weekdayIndex - 1

        var cells: [Int?] = Array(repeating: nil, count: leadingBlanks)
        cells.append(contentsOf: (1...daysInMonth).map { Optional($0) })

        // pad to complete last week row so grid stays even
        let remainder = cells.count % 7
        if remainder != 0 {
            cells.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
        }
        return cells
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Month header
            Text(headerTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.top, 4)

            // Weekday header row
            HStack(spacing: 19) {
                ForEach(weekdayHeaders, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // Grid of days (white numbers only)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    ZStack {
                        if let day = cell {
                            Text("\(day)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 32)
                        } else {
                            Text(" ")
                                .frame(maxWidth: .infinity, minHeight: 32)
                        }
                    }
                    .frame(height: 32)
                }
            }

            // Clear gray divider between months
            Divider()
                .background(Color.gray.opacity(0.9))
                .padding(.top, 6)
        }
    }
}

#Preview {
    CalenderPageView()
}
