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

    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("plan.json")
        load()
    }

    // MARK: - Persistence
    func save(plan: WeeklyPlan) {
        self.plan = plan
        persist()
    }

    func deletePlan() {
        plan = nil
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func persist() {
        guard let plan else { return }
        do {
            let data = try JSONEncoder().encode(plan)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save failed:", error)
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            self.plan = try JSONDecoder().decode(WeeklyPlan.self, from: data)
        } catch {
            print("Load failed:", error)
            self.plan = nil
        }
    }

    // MARK: - Today helpers
    var todayWeekday: Weekday { Weekday.today() }
    var todayPlan: DayPlan? { plan?.day(for: todayWeekday) }
}
