//
//  WeeklyPlan.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import Foundation

struct WeeklyPlan: Codable {
    var days: [DayPlan]
    var createdAt: Date = Date()

    static func blank() -> WeeklyPlan {
        WeeklyPlan(days: Weekday.allCases.map { DayPlan(weekday: $0) })
    }

    func day(for weekday: Weekday) -> DayPlan? {
        days.first(where: { $0.weekday == weekday })
    }

    func index(of weekday: Weekday) -> Int? {
        days.firstIndex(where: { $0.weekday == weekday })
    }
}

extension WeeklyPlan {
    /// Treat as “no plan” if every day is rest with no exercises.
    var isTrulyEmpty: Bool {
        days.allSatisfy { !$0.isWorkoutDay && $0.exercises.isEmpty }
    }
}
