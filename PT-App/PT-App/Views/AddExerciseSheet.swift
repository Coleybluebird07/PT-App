//
//  AddExerciseSheet.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var sets: String
    @State private var reps: String
    @State private var notes: String
    private let editingID: UUID?
    let onSave: (Exercise) -> Void

    init(initial: Exercise?, onSave: @escaping (Exercise) -> Void) {
        _name = State(initialValue: initial?.name ?? "")
        _sets = State(initialValue: initial.map { String($0.sets) } ?? "")
        _reps = State(initialValue: initial.map { String($0.reps) } ?? "")
        _notes = State(initialValue: initial?.notes ?? "")
        self.editingID = initial?.id
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name (e.g. Bench Press)", text: $name)
                        .textInputAutocapitalization(.words)
                }
                Section("Volume") {
                    TextField("Sets", text: $sets).keyboardType(.numberPad)
                    TextField("Reps", text: $reps).keyboardType(.numberPad)
                }
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle(editingID == nil ? "Add Exercise" : "Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let s = Int(sets), let r = Int(reps),
                              !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        onSave(Exercise(id: editingID ?? UUID(),
                                        name: name.trimmingCharacters(in: .whitespaces),
                                        sets: s, reps: r, notes: notes))
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(sets) != nil && Int(reps) != nil
    }
}