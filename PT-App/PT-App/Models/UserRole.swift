//
//  UserProfile.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case client, pt, both

    var displayName: String {
        switch self {
        case .client: return "Client"
        case .pt: return "PT"
        case .both: return "Both"
        }
    }
}

struct UserProfile: Codable, Identifiable {
    var id: String
    var displayName: String
    var role: UserRole
    var linkedClientIds: [String]
    var linkedPTIds: [String]
    var timezoneID: String?

    init(
        id: String,
        displayName: String,
        role: UserRole,
        linkedClientIds: [String] = [],
        linkedPTIds: [String] = [],
        timezoneID: String? = TimeZone.current.identifier
    ) {
        self.id = id
        self.displayName = displayName
        self.role = role
        self.linkedClientIds = linkedClientIds
        self.linkedPTIds = linkedPTIds
        self.timezoneID = timezoneID
    }
}
