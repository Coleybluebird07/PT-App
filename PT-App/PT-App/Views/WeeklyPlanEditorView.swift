//
//  WeeklyPlanEditorView.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct WeeklyPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss

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
                            DayDetailView(day: $day)
                        } label: {
                            HStack(spacing: 12) {
                                Text(day.weekday.rawValue)
                                    .font(.body)
                                    .layoutPriority(1)              // keep the day name from being squeezed first

                                Spacer(minLength: 12)

                                Group {
                                    if day.isWorkoutDay {
                                        HStack(spacing: 6) {
                                            Image(systemName: "figure.strengthtraining.traditional")
                                            Text("\(day.exercises.count) exercise\(day.exercises.count == 1 ? "" : "s")")
                                                .monospacedDigit()
                                        }
                                        .foregroundStyle(.green)
                                    } else {
                                        Text("Rest")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: true, vertical: false)  // ← don’t allow wrapping
                                .frame(minWidth: 98, alignment: .trailing)     // ← reserve space so it won’t get crushed

                                Toggle("", isOn: $day.isWorkoutDay)
                                    .labelsHidden()
                                    .tint(.green)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } header: {
                    Text("Weekly Plan")
                } footer: {
                    Text("Choose workout days, tap a day to add exercises, then Save.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle(initial == nil ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); dismiss() }.tint(.green)
                }
            }
        }
    }
}
