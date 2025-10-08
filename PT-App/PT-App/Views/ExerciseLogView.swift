//
//  ExerciseLogView.swift
//  PT-App
//
//  Created by David Cole on 06/10/2025.
//

import SwiftUI

struct ExerciseLogView: View {
    @EnvironmentObject private var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise
    let weekday: Weekday               // ← which day to update for next week
    @State private var log: ExerciseLog

    @State private var showCongrats = false
    @State private var congratsText = ""

    init(exercise: Exercise, weekday: Weekday) {
        self.exercise = exercise
        self.weekday = weekday
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
                        .monospacedDigit()
                }
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Sets performed") {
                ForEach(Array($log.results.enumerated()), id: \.element.id) { index, $result in
                    HStack {
                        Text("Set \(index + 1)")
                            .frame(width: 60, alignment: .leading)
                            .foregroundStyle(.secondary)

                        Stepper(value: $result.reps, in: 0...200) {
                            Text("Reps: \(result.reps)")
                        }

                        Spacer()

                        TextField("kg", value: $result.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            log.results.remove(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button {
                    log.results.append(SetResult(reps: 0, weight: exercise.defaultWeight))
                } label: {
                    Label("Add another set", systemImage: "plus.circle")
                }
                .tint(.green)
            }

            Section("Notes") {
                TextField("How did it feel? RPE, tempo, cues…", text: $log.notes, axis: .vertical)
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
                Button("Save") {
                    store.upsertLog(log)
                    maybeApplyProgression()   // may show alert and bump next week
                }
                .tint(.green)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        .alert("Well done!", isPresented: $showCongrats) {
            Button("OK") { dismiss() }     // return to Today after message
        } message: {
            Text(congratsText)
        }
        .task {
            // Load or create
            let initial = store.logForToday(exercise: exercise)
            log = initial

            // Prefill weights from default if empty
            if log.results.allSatisfy({ $0.weight == nil }),
               let w = exercise.defaultWeight,
               !log.results.isEmpty {
                for i in log.results.indices { log.results[i].weight = w }
            }

            if log.results.isEmpty && exercise.sets > 0 {
                log.results = (0..<exercise.sets).map { _ in SetResult(reps: 0, weight: exercise.defaultWeight) }
            }
        }
    }

    // MARK: - Progressive overload logic
    private func maybeApplyProgression() {
        guard exercise.progressiveOverload else {
            dismiss(); return
        }

        // Success if user met/beat target reps on each planned set
        let planned = min(exercise.sets, log.results.count)
        let hitAll = (0..<planned).allSatisfy { log.results[$0].reps >= exercise.reps }

        if hitAll {
            let inc = exercise.progressionIncrement ?? 2.5
            store.applyProgression(for: weekday, exerciseId: exercise.id, increment: inc)

            let newTarget = (exercise.defaultWeight ?? 0) + inc
            congratsText = "You hit all \(exercise.sets)×\(exercise.reps). Next week we’ll target \(newTarget.cleanKG) kg."
            showCongrats = true
        } else {
            // No progression this time; just go back
            dismiss()
        }
    }
}

private extension Double {
    var cleanKG: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
