//
//  CurrentDayView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 21/10/2025.
//

import SwiftUI

struct ActivityView: View {
    
   
    
    var body: some View {
        VStack {
            Spacer()
            ToolbarView()
           Spacer() /*.frame(width: 393, height: 46)*/
            VStack(spacing: 44){
               
                CalenderProgressView()
//                    .frame(width: 365, height: 254)
                    
                LogActionButton()
                
            }
            Spacer()
            FreezeButton()
            .frame(width: 274, height: 48)
            
            
                        
            
          
        }
        .preferredColorScheme(.dark)
    }
 }

#Preview {
    ActivityView()
}
