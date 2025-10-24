//
//  ToolbarView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 23/10/2025.
//
import SwiftUI

struct ToolbarView: View {
    // Action closures with safe defaults so previews/builds don't break
    var onCalendarTap: () -> Void = {}
    var onPencilTap:   () -> Void = {}

    var body: some View {
        HStack {
            Text("Activity")
                .font(.system(size: 34, weight: .bold))

            Spacer()

            GlassEffectContainer(spacing: 40.0) {

                Button { onCalendarTap() } label: {
                    Image(systemName:"calendar")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                        .glassEffect()
                }

                Button { onPencilTap() } label: {
                    Image(systemName:"pencil.and.outline")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                        .glassEffect()
                }
            }
        }
        .frame(width: 393, height: 46)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ToolbarView()
}
