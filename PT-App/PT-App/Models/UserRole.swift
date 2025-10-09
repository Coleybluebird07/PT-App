//
//  UserRole.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case client
    case pt
    case both

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .client: return "Client"
        case .pt:     return "PT"
        case .both:   return "Both"
        }
    }
}