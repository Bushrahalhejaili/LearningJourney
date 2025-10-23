//
//  ContentView.swift
//  Learning Journey
//
//  Created by Bushra Hatim Alhejaili on 16/10/2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct OnboardingView: View {
    
    @State private var learningTopic: String = ""
    enum goalDuration {
        case Week , Month , Year
    }
    @State private var goal: goalDuration?
    
    // Text styling
    var textFieldFont: Font = .title3
    var textFieldTextColor: Color = Color(.white)
    var placeholderText: String = "Swift"
    var placeholderColor: Color = Color(.gray)
    
    var flameSize: CGFloat = 40
    var flameColor: Color = .orange
    
    var buttonWidth: CGFloat = 182
    var buttonHeight: CGFloat = 48
    var body: some View {
        VStack{
            
           
                
                VStack {
                    
                    ZStack {
                        
                        Circle()
                            .fill(Color(.brownishOrange))
                            .frame(width: 109, height: 109)
                            .zIndex(0)
                        
                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 109, height: 109)
                            .glassEffect(.clear)
                            .zIndex(1)
                        
                        // Flame symbol on top of both circles
                        Image(systemName: "flame.fill")
                            .symbolRenderingMode(.hierarchical)
                            .resizable()
                            .scaledToFit()
                            .frame(width: flameSize, height: flameSize)
                            .foregroundStyle(flameColor)
                            .zIndex(2)
                        
                    }
                    .padding(.vertical, 50)
                    

                    VStack(alignment: .leading, spacing: 21) {
                        
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello Learner")
                                .foregroundColor(Color(.white))
                                .font(.largeTitle.bold())
                            
                            Text("This app will help you learn everyday!")
                                .foregroundColor(Color(.textGray))
                                .font(.headline.bold())
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                      
                        
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            Text("I want to learn")
                                .foregroundColor(Color(.white))
                                .font(.title2)

                            TextField("Swift", text: $learningTopic)
                                .font(textFieldFont)
                                .foregroundColor(textFieldTextColor)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                            }
                        
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        

                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("I want to learn it in a")
                                .foregroundColor(Color(.white))
                                .font(.title2)
                            
                            HStack{
                                
                                Button(action: {
                                    goal = goal == .Week ?  nil : .Week
                                                                   } ) {
                                    Text("Week")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                    }
                                .frame(width: 97, height: 48)
                                .glassEffect(.clear.tint(.black.opacity(0.65)))
                                .background(
                                    RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                        .fill(goal == .Week ? .lightOrange : .darkishGray))
                                
                                Button(action: {
                                    goal = goal == .Month ?  nil : .Month                                } ) {
                                    Text("Month")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                    }
                                .frame(width: 97, height: 48)
                                .glassEffect(.clear.tint(.black.opacity(0.6)))
                                .background(
                                    RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                        .fill(goal == .Month ? .lightOrange : .darkishGray))
                                
                                Button(action: {
                                    goal = goal == .Year ?  nil : .Year                                 } ) {
                                    Text("Year")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                    }
                                .frame(width: 97, height: 48)
                                .glassEffect(.clear.tint(.black.opacity(0.6)))
                                .background(
                                    RoundedRectangle(cornerRadius: 1000, style: .continuous)
                                        .fill(goal == .Year ? .lightOrange : .darkishGray) )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                            .fill(Color.lightOrange))
                }
                .padding()
            }
        .preferredColorScheme(.dark)
    }
       
    }
       


#Preview {
    OnboardingView()
}
