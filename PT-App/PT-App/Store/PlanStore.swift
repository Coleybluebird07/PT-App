//
//  PlanStore.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//

import Foundation
import Combine

final class PlanStore: ObservableObject {
    @Published var plan: WeeklyPlan? = nil
    @Published var logs: [ExerciseLog] = []

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

    func save(plan: WeeklyPlan) { self.plan = plan; savePlan() }
    func deletePlan() { self.plan = nil; try? FileManager.default.removeItem(at: planURL) }

    private func loadPlan() {
        guard FileManager.default.fileExists(atPath: planURL.path) else { return }
        do { plan = try JSONDecoder().decode(WeeklyPlan.self, from: Data(contentsOf: planURL)) }
        catch { print("Load plan failed:", error); plan = nil }
    }
    private func savePlan() {
        guard let plan else { return }
        do { try JSONEncoder().encode(plan).write(to: planURL, options: .atomic) }
        catch { print("Save plan failed:", error) }
    }

    // MARK: - Logs
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
        do { logs = try JSONDecoder().decode([ExerciseLog].self, from: Data(contentsOf: logsURL)) }
        catch { print("Load logs failed:", error); logs = [] }
    }
    private func saveLogs() {
        do { try JSONEncoder().encode(logs).write(to: logsURL, options: .atomic) }
        catch { print("Save logs failed:", error) }
    }

    // MARK: - Progressive Overload
    /// Increase defaultWeight for the exercise on a specific weekday.
    func applyProgression(for weekday: Weekday, exerciseId: UUID, increment: Double) {
        guard var plan = plan,
              let dayIndex = plan.index(of: weekday),
              let exIndex = plan.days[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId })
        else { return }

        var ex = plan.days[dayIndex].exercises[exIndex]
        let base = ex.defaultWeight ?? 0
        ex.defaultWeight = base + increment
        plan.days[dayIndex].exercises[exIndex] = ex
        self.plan = plan
        savePlan()
    }
}
