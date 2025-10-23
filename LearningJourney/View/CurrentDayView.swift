//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI

struct CurrentDayView: View {
    
    var buttonWidth: CGFloat = 264
    var buttonHeight: CGFloat = 48
    
    var body: some View {
        VStack {
            
           
            
            
            
            VStack{
                Button("Log as Learned") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                .bold()
                .foregroundStyle(Color.white)
                .font(.system(size: 36))
                .padding(100)
                .background(
                    Circle()
                        .fill(Color.richOrange.opacity(0.95))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.4),
                                            Color.white.opacity(0.6),
                                            Color.black.opacity(0.2),
                                            Color.white.opacity(0.9),
                                            Color.black.opacity(0.2),
                                            Color.black.opacity(0.4)
                                        ]),
                                        center: .center
                                    ),  lineWidth: 1
                                    
                                )
                        )
                        .glassEffect()
                        .glassEffect(.clear.interactive())
                    
                )
            }
            
            Spacer()
            Button(action: {
                
            } ) {
                Text("Start Learning")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: buttonWidth, height: buttonHeight)
            .glassEffect(.clear.tint(.black.opacity(0.65)))
            .background(
                RoundedRectangle(cornerRadius: 1000, style: .continuous)
                    .fill(Color.lightBlue))
        }
        .preferredColorScheme(.dark)
    }
 }

#Preview {
    CurrentDayView()
}
