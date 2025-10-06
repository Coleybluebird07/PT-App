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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.name).font(.headline)
                Spacer()
                Text("\(exercise.sets)x\(exercise.reps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
