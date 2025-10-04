//
//  DayDetailView.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct DayDetailView: View {
    @Binding var day: DayPlan
    @State private var showingAdd = false
    @State private var editing: Exercise? = nil

    var body: some View {
        List {
            Section {
                Toggle("Workout day", isOn: $day.isWorkoutDay)
                    .tint(.green)
            }

            Section("Exercises") {
                // Tappable "Add an exercise" row
                Button {
                    editing = nil
                    showingAdd = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                        Text("Add an exercise")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.green)
                    .accessibilityLabel("Add an exercise")
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)

                if day.exercises.isEmpty {
                    // Optional helper text when empty
                    Text(day.isWorkoutDay
                         ? "No exercises yet. Tap “Add an exercise”."
                         : "This is a rest day.")
                    .foregroundStyle(.secondary)
                } else {
                    ForEach(day.exercises) { ex in
                        Button {
                            editing = ex
                            showingAdd = true
                        } label: {
                            ExerciseRow(exercise: ex)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { day.exercises.remove(atOffsets: $0) }
                    .onMove { day.exercises.move(fromOffsets: $0, toOffset: $1) }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle(day.weekday.rawValue)
        .toolbar {
            // Keep Edit for reorder/delete; removed bottom + button
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
        .sheet(isPresented: $showingAdd) {
            AddExerciseSheet(
                initial: editing,
                onSave: { ex in
                    if let i = day.exercises.firstIndex(where: { $0.id == ex.id }) {
                        day.exercises[i] = ex
                    } else {
                        day.exercises.append(ex)
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}
