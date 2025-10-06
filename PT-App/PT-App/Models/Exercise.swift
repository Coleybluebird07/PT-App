//
//  Exercise.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//

import Foundation

struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var sets: Int
    var reps: Int
    var notes: String
    var defaultWeight: Double?   // ← NEW: used to prefill logging (kg)

    init(
        id: UUID = UUID(),
        name: String,
        sets: Int,
        reps: Int,
        notes: String = "",
        defaultWeight: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.notes = notes
        self.defaultWeight = defaultWeight
    }
}
