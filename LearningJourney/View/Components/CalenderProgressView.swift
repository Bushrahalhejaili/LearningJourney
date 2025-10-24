//
//  CalenderProgressView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

import SwiftUI

struct CalenderProgressView: View {
    @State private var anchorDate: Date = Date()
    
    // Picker state
    @State private var showingMonthYearPicker = false
    @State private var pickedMonth: Int = Calendar.current.component(.month, from: Date()) - 1 // 0...11
    @State private var pickedYear: Int = Calendar.current.component(.year, from: Date())

    // Displayed title (e.g. "October 2025")
    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "LLLL yyyy"
        return f.string(from: anchorDate)
    }

    // The 7 dates for the current week (Sun → Sat)
    private var weekDates: [Date] {
        let cal = Calendar(identifier: .gregorian)
        let weekday = cal.component(.weekday, from: anchorDate)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: anchorDate))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var flameSize: CGFloat = 44
    var flameColor: Color = .lightOrange
    var cubeSize: CGFloat = 44
    var cubeColor: Color = .lightBlue

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 20) {
                
                // Month + year + week navigation
                HStack {
                    Text(monthTitle)
                        .font(.system(size: 17, weight: .semibold))
                    
                    // Popover button (chevron)
                    Button(action: {
                        let comps = Calendar.current.dateComponents([.year, .month], from: anchorDate)
                        pickedMonth = (comps.month ?? 1) - 1
                        pickedYear = comps.year ?? pickedYear
                        showingMonthYearPicker = true
                    }) {
                        Image(systemName: showingMonthYearPicker ? "chevron.down" : "chevron.right")
                            .foregroundColor(.orange)
                            .bold()
                    }
                    .popover(isPresented: $showingMonthYearPicker, arrowEdge: .top) {
                        VStack(spacing: 16) {
                            HStack(spacing: 0) {
                                // Month wheel
                                Picker("Month", selection: $pickedMonth) {
                                    let months = DateFormatter().monthSymbols ?? []
                                    ForEach(Array(months.enumerated()), id: \.offset) { index, name in
                                        Text(name).tag(index)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                
                                // Year wheel
                                let currentYear = Calendar.current.component(.year, from: Date())
                                Picker("Year", selection: $pickedYear) {
                                    ForEach(1900...(currentYear + 50), id: \.self) { year in
                                        Text(String(year)).tag(year)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                            }
                            .labelsHidden()
                            .onChange(of: pickedMonth) { _, _ in
                                applyPickedMonthYear()
                            }
                            .onChange(of: pickedYear) { _, _ in
                                applyPickedMonthYear()
                            }
                        }
                        .presentationCompactAdaptation(.popover)
                        .padding()
//                        .glassEffect(in: RoundedRectangle(cornerRadius: 13))
                        
                        
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut) { anchorDate = shiftWeek(by: -1) }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.orange).bold()
                    }
                    .padding(.trailing)
                    
                    Button {
                        withAnimation(.easeInOut) { anchorDate = shiftWeek(by: 1) }
                    } label: {
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.orange).bold()
                    }
                }
                
                // Day names + dates
                VStack {
                    HStack(spacing: 17) {
                        ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        ForEach(weekDates, id: \.self) { date in
                            ZStack {
                                Circle().fill(Color("IdleCircle"))
                                Text(dayNumber(from: date))
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 36, height: 36)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Divider()
                
                // Learning progress section
                VStack(spacing: 12) {
                    Text("Learning Swift")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        // Days Learned
                        HStack {
                            Image(systemName: "flame.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                                .frame(width: flameSize, height: flameSize)
                                .foregroundStyle(flameColor)
                            VStack(alignment:.leading) {
                                Text("3")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                Text("Days Learned")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        }
                        .frame(width: 160, height: 69)
                        .background(Color(.brownie))
                        .cornerRadius(50)
                        .glassEffect(.clear.tint(.darkishBlue))
                        
                        // Days Frozen
                        HStack {
                            Image(systemName: "cube.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                                .frame(width: cubeSize, height: cubeSize)
                                .foregroundStyle(cubeColor)
                            VStack(alignment:.leading) {
                                Text("1")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                Text("Days Freezed")
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
            
            .preferredColorScheme(.dark)
            .cornerRadius(13)
            .padding()
            .glassEffect(.clear, in: .rect(cornerRadius: 13))
            .frame(width: 365, height: 254)
            
            
        }
    }
    // MARK: - Helpers
    private func shiftWeek(by offset: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: offset * 7, to: anchorDate)!
    }

    private func dayNumber(from date: Date) -> String {
        String(Calendar(identifier: .gregorian).component(.day, from: date))
    }

    private func applyPickedMonthYear() {
        var comps = DateComponents()
        comps.year = pickedYear
        comps.month = pickedMonth + 1
        comps.day = 1
        if let composed = Calendar.current.date(from: comps) {
            anchorDate = composed
        }
    }
}

#Preview {
    CalenderProgressView()
}
