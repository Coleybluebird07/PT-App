//
//  PlanStore.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//


import Foundation
import Combine

final class PlanStore: ObservableObject {
    // Current weekly plan
    @Published var plan: WeeklyPlan? = nil

    // Exercise logs (actual performance)
    @Published var logs: [ExerciseLog] = []

    // File URLs
    private let planURL: URL
    private let logsURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        planURL = docs.appendingPathComponent("plan.json")
        logsURL = docs.appendingPathComponent("logs.json")
        loadPlan()
        loadLogs()
    }

    // MARK: - Plan helpers
    var todayWeekday: Weekday { Weekday.today() }
    var todayPlan: DayPlan? { plan?.day(for: todayWeekday) }

    var hasUsablePlan: Bool { !(plan?.isTrulyEmpty ?? true) }
    var todayPlanIfUsable: DayPlan? { hasUsablePlan ? todayPlan : nil }

    func save(plan: WeeklyPlan) {
        self.plan = plan
        savePlan()
    }

    func deletePlan() {
        self.plan = nil
        try? FileManager.default.removeItem(at: planURL)
    }

    private func loadPlan() {
        guard FileManager.default.fileExists(atPath: planURL.path) else { return }
        do {
            let data = try Data(contentsOf: planURL)
            self.plan = try JSONDecoder().decode(WeeklyPlan.self, from: data)
        } catch {
            print("Load plan failed:", error)
            self.plan = nil
        }
    }

    private func savePlan() {
        guard let plan else { return }
        do {
            let data = try JSONEncoder().encode(plan)
            try data.write(to: planURL, options: .atomic)
        } catch {
            print("Save plan failed:", error)
        }
    }

    // MARK: - Logs helpers
    func logForToday(exercise: Exercise) -> ExerciseLog {
        let key = ExerciseLog.makeDateKey(Date())
        if let existing = logs.first(where: { $0.exerciseId == exercise.id && $0.dateKey == key }) {
            return existing
        }
        return ExerciseLog(exerciseId: exercise.id, date: Date(), setCount: exercise.sets)
    }

    func upsertLog(_ log: ExerciseLog) {
        if let i = logs.firstIndex(where: { $0.id == log.id }) {
            logs[i] = log
        } else if let i = logs.firstIndex(where: { $0.exerciseId == log.exerciseId && $0.dateKey == log.dateKey }) {
            logs[i] = log
        } else {
            logs.append(log)
        }
        saveLogs()
    }

    private func loadLogs() {
        guard FileManager.default.fileExists(atPath: logsURL.path) else { return }
        do {
            let data = try Data(contentsOf: logsURL)
            self.logs = try JSONDecoder().decode([ExerciseLog].self, from: data)
        } catch {
            print("Load logs failed:", error)
            self.logs = []
        }
    }

    private func saveLogs() {
        do {
            let data = try JSONEncoder().encode(logs)
            try data.write(to: logsURL, options: .atomic)
        } catch {
            print("Save logs failed:", error)
        }
    }
}
