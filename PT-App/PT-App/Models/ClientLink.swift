//
//  ClientLink.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import Foundation

struct ClientLink: Identifiable, Codable, Equatable {
    enum Status: String, Codable { case pending, active, revoked }

    let id: String                 // relId
    let ptId: String
    let clientId: String
    var status: Status
    var createdAt: Date

    init(id: String = UUID().uuidString,
         ptId: String,
         clientId: String,
         status: Status = .active,
         createdAt: Date = .now) {
        self.id = id
        self.ptId = ptId
        self.clientId = clientId
        self.status = status
        self.createdAt = createdAt
    }
}