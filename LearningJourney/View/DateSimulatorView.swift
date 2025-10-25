//
//  DateSimulatorView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

import SwiftUI

struct DateSimulatorView: View {
    var progress: LearningProgress
    
    @State private var displayDate = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🧪 Testing Mode")
                .font(.headline)
                .foregroundColor(.yellow)
            
            Text(displayDate, style: .date)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                Button {
                    progress.goToPreviousDay()
                    updateDisplayDate()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                
                Button("Today") {
                    progress.resetToRealDate()
                    updateDisplayDate()
                }
                .foregroundColor(.white)
                
                Button {
                    progress.advanceToNextDay()
                    updateDisplayDate()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            updateDisplayDate()
        }
    }
    
    private func updateDisplayDate() {
        // Use a method to get the current date
        displayDate = progress.simulatedDate ?? Date()
    }
}

#Preview {
    DateSimulatorView(progress: LearningProgress())
        .preferredColorScheme(.dark)
}
