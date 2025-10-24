//
//  FreezeButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

import SwiftUI

struct FreezeButton: View {
    
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48
    
    var body: some View {
        Button(action: {
            
        } ) {
            Text("Log as Freezed")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
        }
        .frame(width: buttonWidth, height: buttonHeight)
        .glassEffect(.clear.tint(.black.opacity(0.65)))
        .background(
            RoundedRectangle(cornerRadius: 1000, style: .continuous)
                .fill(Color.lightBlue))
        
        
        .preferredColorScheme(.dark)
    }
    

    }

#Preview {
    FreezeButton()
}
