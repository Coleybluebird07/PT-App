//
//  TodayView.swift
//  PT-App
//
//  Created by David Cole on 06/10/2025.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: PlanStore
    let today: DayPlan
    let onEdit: () -> Void
    let onNew: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Today: \(today.weekday.rawValue)")
                .font(.title2.weight(.semibold))

            if today.isWorkoutDay {
                Text("You have a workout today").font(.headline)

                if today.exercises.isEmpty {
                    Text("No exercises added to today yet.")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 10) {
                        ForEach(today.exercises) { ex in
                            NavigationLink {
                                ExerciseLogView(exercise: ex)
                            } label: {
                                HStack {
                                    ExerciseRow(exercise: ex)
                                    Spacer()
                                    if isCompletedToday(ex) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Rest day").font(.headline)
                Text("No workout scheduled.").foregroundStyle(.secondary)
            }

            HStack {
                Button("Edit plan", action: onEdit)
                Spacer()
                Button("New plan", action: onNew)
                Spacer()
                Button(role: .destructive, action: onDelete) { Text("Delete plan") }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
    }

    private func isCompletedToday(_ ex: Exercise) -> Bool {
        let key = ExerciseLog.makeDateKey(Date())
        return store.logs.first(where: { $0.exerciseId == ex.id && $0.dateKey == key })?.completed == true
    }
}

#Preview {
    TodayView(
        today: DayPlan(weekday: .monday, isWorkoutDay: true, exercises: [
            Exercise(name: "Bench Press", sets: 3, reps: 8),
            Exercise(name: "Pull Ups", sets: 3, reps: 6)
        ]),
        onEdit: {}, onNew: {}, onDelete: {}
    )
    .environmentObject(PlanStore())
    .preferredColorScheme(.dark)
}
