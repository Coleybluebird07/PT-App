//
//  WeeklyPlan.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import Foundation

struct WeeklyPlan: Identifiable, Codable {
    var id: String = UUID().uuidString   // 🔥 unique plan ID
    var name: String = "My Plan"
    var days: [DayPlan]
    var createdAt: Date = Date()

    init(id: String = UUID().uuidString, name: String = "My Plan", days: [DayPlan]) {
        self.id = id
        self.name = name
        self.days = days
        self.createdAt = Date()
    }
}

extension WeeklyPlan {
    static func blank() -> WeeklyPlan {
        return WeeklyPlan(name: "New Plan", days: [])
    }
}

extension WeeklyPlan {
    /// Returns the plan for the given weekday
    func day(for weekday: Weekday) -> DayPlan? {
        return days.first { $0.weekday == weekday }
    }

    /// Checks if the plan has no workout days or all rest days
    var isTrulyEmpty: Bool {
        return days.isEmpty || days.allSatisfy { !$0.isWorkoutDay }
    }
}

extension WeeklyPlan {
    /// Finds the index of a DayPlan for a given weekday
    func index(of weekday: Weekday) -> Int? {
        return days.firstIndex { $0.weekday == weekday }
    }
}
