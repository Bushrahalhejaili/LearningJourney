//
//  NewGoalButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//
import SwiftUI

struct NewGoalButton: View {
    var progress: LearningProgress
    
    @State private var goToLearningGoal: Bool = false
    
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48
    
    var body: some View {
        VStack{
            Button {
                goToLearningGoal = true
            } label: {
                Text("Set new learning goal")
                    .font(.custom("SF Pro", size: 17))
                    .foregroundStyle(.white)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(
                        RoundedRectangle(cornerRadius: 1000, style: .continuous)
                            .fill(Color.lightOrange)
                    )
                    .padding()
            }
            .navigationDestination(isPresented: $goToLearningGoal) {
                LearningGoalView(progress: progress, isUpdatingMidway: false)
                    .navigationTitle("Learning Goal")
                    .navigationBarTitleDisplayMode(.inline)
            }
            
            Button("Set same learning goal and duration") {
                // Reset progress but keep calendar history
                progress.resetGoalKeepHistory()
            }
            .font(.custom("SF Pro", size: 17))
            .foregroundStyle(.lightOrange)
            
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NewGoalButton(progress: LearningProgress())
}
