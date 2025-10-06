//
//  Weekday.swift
//  PT-App
//
//  Created by David Cole on 05/10/2025.
//

import Foundation

enum Weekday: String, CaseIterable, Codable, Identifiable {
    case monday = "Monday", tuesday = "Tuesday", wednesday = "Wednesday",
         thursday = "Thursday", friday = "Friday", saturday = "Saturday",
         sunday = "Sunday"

    var id: String { rawValue }

    static func today(calendar: Calendar = .current) -> Weekday {
        // Apple weekday: 1=Sun ... 7=Sat
        switch calendar.component(.weekday, from: Date()) {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }
}
