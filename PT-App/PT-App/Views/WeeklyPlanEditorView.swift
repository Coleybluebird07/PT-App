//
//  WeeklyPlanEditorView.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct WeeklyPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss

    // If nil => creating a new blank plan. If non-nil => editing existing.
    let initial: WeeklyPlan?
    let onSave: (WeeklyPlan) -> Void

    @State private var draft: WeeklyPlan

    init(initial: WeeklyPlan?, onSave: @escaping (WeeklyPlan) -> Void) {
        self.initial = initial
        self.onSave = onSave
        _draft = State(initialValue: initial ?? .blank())
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($draft.days) { $day in
                        NavigationLink {
                            DayDetailView(day: $day) // uses your tappable “Add an exercise” row
                        } label: {
                            HStack(spacing: 12) {
                                Text(day.weekday.rawValue)
                                Spacer()
                                if day.isWorkoutDay {
                                    Label("\(day.exercises.count) exercise\(day.exercises.count == 1 ? "" : "s")",
                                          systemImage: "figure.strengthtraining.traditional")
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Rest").foregroundStyle(.secondary)
                                }
                                Toggle("", isOn: $day.isWorkoutDay)
                                    .labelsHidden()
                                    .tint(.green)
                            }
                        }
                    }
                } header: {
                    Text("Weekly Plan")
                } footer: {
                    Text("Choose your workout days, tap a day to add exercises, then tap Save.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle(initial == nil ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .tint(.green)
                }
            }
        }
    }
}