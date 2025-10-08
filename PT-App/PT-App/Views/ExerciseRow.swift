//
//  ExerciseRow.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise.name).font(.headline)
                Spacer()
                Text("\(exercise.sets)x\(exercise.reps)")
                    .font(.subheadline)
                    .foregroundStyle(PT.textSub)
                    .monospacedDigit()
            }
            if let w = exercise.defaultWeight {
                Text("\(formattedKG(w)) kg default")
                    .font(.footnote)
                    .foregroundStyle(PT.textSub)
            } else if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.footnote)
                    .foregroundStyle(PT.textSub)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedKG(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}

#Preview {
    ExerciseRow(exercise: Exercise(name: "Bench Press", sets: 3, reps: 8, defaultWeight: 60))
        .preferredColorScheme(.dark)
}
