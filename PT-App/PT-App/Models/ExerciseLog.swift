//
//  ExerciseLog.swift
//  PT-App
//
//  Created by David Cole on 06/10/2025.
//

import Foundation

struct SetResult: Identifiable, Codable, Hashable {
    let id: UUID = UUID()
    var reps: Int
    var weight: Double? // kg (nil = bodyweight)
}

struct ExerciseLog: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let dateKey: String        // "yyyy-MM-dd"
    var results: [SetResult]
    var notes: String
    var completed: Bool

    init(exerciseId: UUID, date: Date = Date(), setCount: Int) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.dateKey = ExerciseLog.makeDateKey(date)
        self.results = (0..<max(setCount, 1)).map { _ in SetResult(reps: 0, weight: nil) }
        self.notes = ""
        self.completed = false
    }

    static func makeDateKey(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.locale = Locale(identifier: "en_GB")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
