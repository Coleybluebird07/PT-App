//
//  ExerciseLogView.swift
//  PT-App
//
//  Created by David Cole on 06/10/2025.
//


import SwiftUI

struct ExerciseLogView: View {
    @EnvironmentObject private var store: PlanStore
    let exercise: Exercise

    @State private var log: ExerciseLog

    init(exercise: Exercise) {
        self.exercise = exercise
        _log = State(initialValue: ExerciseLog(exerciseId: exercise.id, setCount: exercise.sets))
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(exercise.name).font(.headline)
                    Spacer()
                    Text("\(exercise.sets)x\(exercise.reps)")
                        .foregroundStyle(.secondary)
                }
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Sets") {
                ForEach(Array($log.results.enumerated()), id: \.element.id) { index, $set in
                    HStack {
                        Text("Set \(index + 1)")
                            .frame(width: 60, alignment: .leading)
                            .foregroundStyle(.secondary)

                        TextField("Reps", value: $set.reps, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)

                        TextField("Weight (kg)", value: $set.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .textFieldStyle(.roundedBorder)
                    }
                    // 💥 Add this to enable swipe-to-delete
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            log.results.remove(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button {
                    log.results.append(SetResult(reps: 0, weight: nil))
                } label: {
                    Label("Add another set", systemImage: "plus.circle")
                }
                .tint(.green)
            }

            Section("Notes") {
                TextField("How did it feel? RPE, tempo, form cues…", text: $log.notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }

            Section {
                Toggle("Mark as completed", isOn: $log.completed)
            }
        }
        .navigationTitle("Log: \(exercise.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { store.upsertLog(log) }
                    .tint(.green)
            }
        }
        .task {
            let initial = store.logForToday(exercise: exercise)
            log = initial
            if log.results.isEmpty && exercise.sets > 0 {
                log.results = (0..<exercise.sets).map { _ in SetResult(reps: 0, weight: nil) }
            }
        }
    }
}
