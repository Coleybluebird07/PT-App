//
//  AddExerciseSheet.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import SwiftUI

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    // Editing support
    private let editingID: UUID?
    let onSave: (Exercise) -> Void

    // Fields
    @State private var name: String
    @State private var setsInt: Int
    @State private var repsInt: Int
    @State private var notes: String

    // Keyboard focus
    @FocusState private var focused: Field?

    private enum Field: Hashable {
        case name, sets, reps, notes
    }

    // MARK: - Init
    init(initial: Exercise?, onSave: @escaping (Exercise) -> Void) {
        self.editingID = initial?.id
        self.onSave = onSave
        _name    = State(initialValue: initial?.name  ?? "")
        _setsInt = State(initialValue: initial?.sets  ?? 3)
        _repsInt = State(initialValue: initial?.reps  ?? 8)
        _notes   = State(initialValue: initial?.notes ?? "")
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name (e.g. Bench Press)", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($focused, equals: .name)
                }

                Section("Volume") {
                    HStack {
                        Text("Sets")
                        Spacer()
                        // Numeric keypad
                        TextField("Sets", value: $setsInt, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                            .textFieldStyle(.roundedBorder)
                            .focused($focused, equals: .sets)
                            .monospacedDigit()
                            .accessibilityLabel("Number of sets")
                    }

                    HStack {
                        Text("Reps")
                        Spacer()
                        // Numeric keypad
                        TextField("Reps", value: $repsInt, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                            .textFieldStyle(.roundedBorder)
                            .focused($focused, equals: .reps)
                            .monospacedDigit()
                            .accessibilityLabel("Number of reps per set")
                    }
                }

                Section("Notes") {
                    TextField("Optional notes (tempo, cues, etc.)", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .focused($focused, equals: .notes)
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
                    Button("Save") { save() }
                        .tint(.green)
                        .disabled(!canSave)
                }
                // Keyboard accessory bar with Done
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
    }

    // MARK: - Helpers
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        setsInt > 0 && repsInt > 0
    }

    private func save() {
        guard canSave else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let exercise = Exercise(
            id: editingID ?? UUID(),
            name: trimmed,
            sets: setsInt,
            reps: repsInt,
            notes: notes
        )
        onSave(exercise)
        dismiss()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddExerciseSheet(
        initial: Exercise(name: "Bench Press", sets: 3, reps: 8),
        onSave: { _ in }
    )
    .preferredColorScheme(.dark)
}
