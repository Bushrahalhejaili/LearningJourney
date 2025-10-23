//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI

struct CurrentDayView: View {
    @State private var anchorDate: Date = Date()

    // e.g. "October 2025"
    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "LLLL yyyy"
        return f.string(from: anchorDate)
    }

    // The 7 dates for the current week (Sun → Sat)
    private var weekDates: [Date] {
        let cal = Calendar(identifier: .gregorian)
        let weekday = cal.component(.weekday, from: anchorDate) // 1=Sun ... 7=Sat
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1),
                                   to: cal.startOfDay(for: anchorDate))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var flameSize: CGFloat = 44
    var flameColor: Color = .lightOrange
    
    var cubeSize: CGFloat = 44
    var cubeColor: Color = .lightBlue
    
    var body: some View {
        VStack {
            
            HStack{
                
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
                
                ZStack{
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        .blur(radius: 1)
                        .glassEffect()
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .bold))
                }
                
                ZStack{
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        .blur(radius: 1)
                        .glassEffect()
                        .frame(width: 44, height: 44)
                
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 22, weight: .bold))
                }

            
        
    
                
            }
 
            
            VStack(spacing: 16) {

                // Month + year + week navigation
                HStack {
                    Text(monthTitle)
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.orange).bold()

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

                VStack(spacing: 4) {

                    // Day names (SUN–SAT)
                    HStack {
                        ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        }
                    }

                    // Dates row (view-only)
                    HStack {
                        ForEach(weekDates, id: \.self) { date in
                            ZStack {
                                // Placeholder fill — later choose color from your data:
                                // "IdleCircle" / "LearnedCircle" / "FrozenCircle"
                                Circle()
                                    .fill(Color("IdleCircle"))

                                Text(dayNumber(from: date))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 36, height: 36)
                            .frame(maxWidth: .infinity) // equal spacing across the row
                            .contentShape(Circle())
                        }
                    }
                    
                    Divider()
                        .padding()
                    VStack(spacing: 12) {
                        Text("Learning Swift")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 12){
                                
                                HStack(spacing: 0){
                                    
                                    // Flame symbol on top of both circles
                                    Image(systemName: "flame.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .scaledToFit()
                                        .frame(width: flameSize, height: flameSize)
                                        .foregroundStyle(flameColor)
                                        .zIndex(2)
                                    
                                    
                                    VStack(alignment:.leading){
                                        Text("3")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24, weight: .semibold))
                                        
                                        Text("Days Learned")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular ))
                                        
                                    }
                                    //
                                }.frame(width: 160, height: 69)
                                .background(Color(.brownie))
                                .cornerRadius(50)
                          
                            Spacer().frame(width: 5)
                               .glassEffect(.clear.tint(.darkishBlue))
                                
                                HStack{
                                    
                                    // Flame symbol on top of both circles
                                    Image(systemName: "cube.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .scaledToFit()
                                        .frame(width: cubeSize, height: cubeSize)
                                        .foregroundStyle(cubeColor)
                                        .zIndex(2)
                                    
                                    
                                    VStack(alignment:.leading){
                                        Text("1")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24, weight: .semibold))
                                        
                                        Text("Day Freezed")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular ))
                                        
                                    }
                                    
                                    
                                    
                                }.frame(width: 160, height: 69)
                                .background(Color(.darkishBlue))
                                .cornerRadius(50)
                            
                        }
                        
                    }
                    
                    
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .glassEffect(.clear, in: .rect(cornerRadius: 8))
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    /// Move the anchor week forward/backward by `offset` weeks.
    private func shiftWeek(by offset: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: offset * 7, to: anchorDate)!
    }

    /// Day number string (e.g., "24") from a Date.
    private func dayNumber(from date: Date) -> String {
        String(Calendar(identifier: .gregorian).component(.day, from: date))
    }
}

#Preview {
    CurrentDayView()
}
