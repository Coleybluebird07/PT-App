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
    @State private var showConfirmClear = false
    @State private var pendingTurnOff = false

    var body: some View {
        List {
            Section {
                Toggle("Workout day", isOn: $day.isWorkoutDay)
                    .tint(.green)
            }

            Section("Exercises") {
                Button {
                    editing = nil
                    showingAdd = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill").imageScale(.large)
                        Text("Add an exercise").font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)

                if day.exercises.isEmpty {
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
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle(day.weekday.rawValue)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { EditButton() } }
        .sheet(isPresented: $showingAdd) {
            AddExerciseSheet(
                initial: editing,
                onSave: { ex in
                    if let i = day.exercises.firstIndex(where: { $0.id == ex.id }) {
                        day.exercises[i] = ex
                    } else {
                        day.exercises.append(ex)
                        if !day.isWorkoutDay { day.isWorkoutDay = true } // auto ON
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        // iOS 17+ two-parameter onChange
        .onChange(of: day.isWorkoutDay) { old, new in
            guard old != new else { return }
            if !new && !day.exercises.isEmpty {
                pendingTurnOff = true
                showConfirmClear = true
            }
        }
        .onChange(of: day.exercises) { _, new in
            if new.isEmpty && day.isWorkoutDay { day.isWorkoutDay = false } // auto OFF
        }
        .alert("Turn this into a rest day?", isPresented: $showConfirmClear) {
            Button("Cancel", role: .cancel) {
                if pendingTurnOff { day.isWorkoutDay = true }
                pendingTurnOff = false
            }
            Button("Turn Off & Clear", role: .destructive) {
                day.exercises.removeAll()
                day.isWorkoutDay = false
                pendingTurnOff = false
            }
        } message: {
            Text("This will clear all exercises for this day.")
        }
    }

    private func delete(at offsets: IndexSet) {
        day.exercises.remove(atOffsets: offsets)
        if day.exercises.isEmpty && day.isWorkoutDay { day.isWorkoutDay = false }
    }

    private func move(from source: IndexSet, to destination: Int) {
        day.exercises.move(fromOffsets: source, toOffset: destination)
    }
}
