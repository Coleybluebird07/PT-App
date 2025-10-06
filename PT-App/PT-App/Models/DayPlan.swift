//
//  DayPlan.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import Foundation

struct DayPlan: Identifiable, Codable {
    let id: UUID = UUID()
    var weekday: Weekday
    var isWorkoutDay: Bool = false
    var exercises: [Exercise] = []
}