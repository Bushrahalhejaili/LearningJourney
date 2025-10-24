//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI

struct ActivityView: View {
    // receive values from Onboarding
    var learningTopic: String
    var goalDuration: String   // kept for future use (e.g., summary text)

    @State private var goToCalendar: Bool = false

    var body: some View {
        VStack {
            

            Spacer()

            // Tell the toolbar how to trigger navigation
            ToolbarView(onCalendarTap: {
                goToCalendar = true
            })

            Spacer()

            VStack(spacing: 44) {
                CalenderProgressView(learningTopic: learningTopic)
                LogActionButton()
            }

            Spacer()
            FreezeButton()
                .frame(width: 274, height: 48)
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)

        // ✅ New modern API: present destination when goToCalendar becomes true
        .navigationDestination(isPresented: $goToCalendar) {
            CalenderPageView()
        }
    }
}

#Preview {
    NavigationStack {
        ActivityView(learningTopic: "Swift", goalDuration: "Month")
    }
}
