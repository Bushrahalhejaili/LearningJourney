//
//  GoalCompletedView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 03/05/1447 AH.
//

import SwiftUI

var clapSize: CGFloat = 55
var clapColor: Color = .lightOrange

struct GoalCompletedView: View {
    var fontWeight: Font.Weight = .bold
    
    var body: some View {
        VStack(spacing: 4){
           Image(systemName: "hands.and.sparkles.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .frame(width: clapSize, height: clapSize)
                .foregroundStyle(clapColor)
            
            Text("Well done!")
                .font(.system(size: 22, weight: fontWeight))


            Text("Goal completed! start learning again or set a new learning goal")
                .font(.custom("SF Pro", size: 18))
                .foregroundColor(Color(.gray))
                .padding()
                .multilineTextAlignment(.center)
                
            
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GoalCompletedView()
}
