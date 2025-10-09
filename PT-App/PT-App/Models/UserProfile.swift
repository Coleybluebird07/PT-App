//
//  UserProfile.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    let id: String                // uid (local UUID for now)
    var displayName: String
    var role: UserRole
    var timezoneID: String

    // Lightweight lists for UI; real app will fetch details via relationships
    var linkedPTIds: [String] = []
    var linkedClientIds: [String] = []

    init(id: String = UUID().uuidString,
         displayName: String = "You",
         role: UserRole = .client,
         timezoneID: String = TimeZone.current.identifier) {
        self.id = id
        self.displayName = displayName
        self.role = role
        self.timezoneID = timezoneID
    }
}