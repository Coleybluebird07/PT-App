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
                            // --- Updated row to avoid wrapping + nicer status ---
                            HStack(spacing: 12) {
                                Text(day.weekday.rawValue)
                                    .layoutPriority(1)

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
                                        Text("Rest").foregroundStyle(PT.textSub)
                                    }
                                }
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(minWidth: 98, alignment: .trailing)

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
            .background(LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom))
            .navigationTitle(initial == nil ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); Haptics.success(); dismiss() }.tint(.green)
                }
            }
        }
    }
}

#Preview {
    WeeklyPlanEditorView(initial: .blank()) { _ in }
        .preferredColorScheme(.dark)
}
