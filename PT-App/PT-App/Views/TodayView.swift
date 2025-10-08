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
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                Text("Today: \(today.weekday.rawValue)")
                    .font(.title2.weight(.semibold))
                Spacer()
                if today.isWorkoutDay {
                    Label(isCompletedTodayWholeDay ? "Completed" : "Workout",
                          systemImage: isCompletedTodayWholeDay ? "checkmark.circle.fill" : "bolt.heart.fill")
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 10).fill(PT.cardBg))
                        .foregroundStyle(isCompletedTodayWholeDay ? .green : .orange)
                        .font(.footnote.weight(.semibold))
                } else {
                    Text("Rest")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 10).fill(PT.cardBg))
                        .foregroundStyle(PT.textSub)
                }
            }

            // Content
            if today.isWorkoutDay {
                if today.exercises.isEmpty {
                    Text("No exercises added to today yet.")
                        .foregroundStyle(PT.textSub)
                } else {
                    VStack(spacing: 10) {
                        ForEach(today.exercises) { ex in
                            NavigationLink {
                                ExerciseLogView(exercise: ex, weekday: today.weekday)
                            } label: {
                                HStack(spacing: 12) {
                                    ExerciseRow(exercise: ex)
                                    Spacer(minLength: 8)
                                    if isCompletedToday(ex) {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                    }
                                    Image(systemName: "chevron.right").foregroundStyle(PT.textSub)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .ptCard()
                        }
                    }
                }
            } else {
                Text("No workout scheduled.")
                    .foregroundStyle(PT.textSub)
            }

            // Adaptive actions
            ViewThatFits(in: .horizontal) {
                // 1) Wide layout: three inline buttons (stays on one line)
                HStack(spacing: 10) {
                    Button("Edit plan", action: onEdit)
                        .buttonStyle(SubtleButtonStyle())
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Button("New plan", action: onNew)
                        .buttonStyle(SubtleButtonStyle())
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Button(role: .destructive, action: onDelete) {
                        Text("Delete plan")
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .buttonStyle(SubtleButtonStyle())
                }
                .frame(maxWidth: .infinity)

                // 2) Fallback when space is tight: compact menu
                HStack {
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit plan", systemImage: "pencil")
                        }
                        Button(action: onNew) {
                            Label("New plan", systemImage: "calendar.badge.plus")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete plan", systemImage: "trash")
                        }
                    } label: {
                        Label("Plan actions", systemImage: "ellipsis.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SubtleButtonStyle())
                }
            }
            .padding(.top, 6)
        }
        .ptCard()
    }

    private func isCompletedToday(_ ex: Exercise) -> Bool {
        let key = ExerciseLog.makeDateKey(Date())
        return store.logs.first(where: { $0.exerciseId == ex.id && $0.dateKey == key })?.completed == true
    }

    private var isCompletedTodayWholeDay: Bool {
        today.exercises.allSatisfy { isCompletedToday($0) } && !today.exercises.isEmpty
    }
}

#Preview {
    TodayView(
        today: DayPlan(
            weekday: .wednesday,
            isWorkoutDay: true,
            exercises: [
                Exercise(name: "Hello Again", sets: 3, reps: 8, defaultWeight: 40),
            ]
        ),
        onEdit: {}, onNew: {}, onDelete: {}
    )
    .environmentObject(PlanStore())
    .preferredColorScheme(.dark)
}
