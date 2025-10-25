//
//  LearningGoalView.swift
//  LearningJourney
//
//  Created by Bushra Hatim Alhejaili on 24/10/2025.
//
import SwiftUI

struct LearningGoalView: View {
    var progress: LearningProgress
    
    @State private var learningTopic: String = ""
    enum goalDuration { case Week , Month , Year }
    @State private var goal: goalDuration?
    
    @Environment(\.dismiss) var dismiss

    // Text styling
    var textFieldFont: Font = .title3
    var textFieldTextColor: Color = Color(.white)
    var placeholderText: String = "Swift"
    var placeholderColor: Color = Color(.gray)
    
    private var durationLabel: String {
        switch goal {
        case .Week:  return "Week"
        case .Month: return "Month"
        case .Year:  return "Year"
        case .none:  return ""
        }
    }

    var body: some View {
        VStack(spacing: 24) {

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

                HStack {
                    Button(action: { goal = goal == .Week  ? nil : .Week  }) {
                        Text("Week").font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity)
                    }
                    .frame(width: 97, height: 48)
                    .glassEffect(.clear.tint(.black.opacity(0.65)))
                    .background(RoundedRectangle(cornerRadius: 1000, style: .continuous)
                        .fill(goal == .Week ? .lightOrange : .darkishGray))

                    Button(action: { goal = goal == .Month ? nil : .Month }) {
                        Text("Month").font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity)
                    }
                    .frame(width: 97, height: 48)
                    .glassEffect(.clear.tint(.black.opacity(0.6)))
                    .background(RoundedRectangle(cornerRadius: 1000, style: .continuous)
                        .fill(goal == .Month ? .lightOrange : .darkishGray))

                    Button(action: { goal = goal == .Year  ? nil : .Year  }) {
                        Text("Year").font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity)
                    }
                    .frame(width: 97, height: 48)
                    .glassEffect(.clear.tint(.black.opacity(0.6)))
                    .background(RoundedRectangle(cornerRadius: 1000, style: .continuous)
                        .fill(goal == .Year ? .lightOrange : .darkishGray))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !learningTopic.isEmpty && goal != nil {
                    Button {
                        // Update progress with new goal
                        progress.learningTopic = learningTopic.trimmingCharacters(in: .whitespacesAndNewlines)
                        progress.goalDuration = durationLabel
                        progress.resetStreak()
                        progress.goalStartDate = Calendar.current.startOfDay(for: progress.simulatedDate ?? Date())
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                        
                            .glassEffect(.regular.tint(.lightOrange.opacity(0.4)))

                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LearningGoalView(progress: LearningProgress())
    }
}


//Image(systemName: "checkmark")
//    .foregroundColor(.white)
//    
//    .glassEffect(.regular.tint(.lightOrange.opacity(0.4)))
