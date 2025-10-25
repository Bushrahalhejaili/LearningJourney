//
//  FreezeButton.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//

import SwiftUI

struct FreezeButton: View {
    var progress: LearningProgress
    
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48
    
    private var isDisabled: Bool {
        return progress.isTodayLogged() || progress.isTodayFreezed() || !progress.hasFreezesRemaining
    }
    
    private var buttonColor: Color {
        return progress.hasFreezesRemaining ? .lightBlue : .darkishBlue
    }
    
    private var freezeText: String {
        let remaining = progress.freezesRemaining
        let total = progress.maxFreezes
        let used = total - remaining
        return "\(used) out of \(total) Freezes used"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                progress.freezeToday()
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
                    .fill(buttonColor))
            .disabled(isDisabled)
            
            Text(freezeText)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FreezeButton(progress: LearningProgress())
}
