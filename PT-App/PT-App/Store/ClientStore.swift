//
//  ClientStore.swift
//  PT-App
//
//  Created by David Cole on 09/10/2025.
//


import SwiftUI
import Combine            // 👈 add this
import FirebaseFirestore

@MainActor
final class ClientStore: ObservableObject {
    @Published var clients: [UserProfile] = []
    @Published var errorMessage: String? = nil

    func fetchClients(for ptId: String) async {
        do {
            let fetched = try await FirebaseManager.shared.fetchClients(for: ptId)
            var result: [UserProfile] = []
            for link in fetched {
                if let client = try await FirebaseManager.shared.fetchUserProfile(id: link.clientId) {
                    result.append(client)
                }
            }
            self.clients = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addClient(for ptId: String, displayName: String) async {
        do {
            let newClient = UserProfile(id: UUID().uuidString, displayName: displayName, role: .client)
            try await FirebaseManager.shared.createUserProfile(user: newClient)
            try await FirebaseManager.shared.linkClient(ptId: ptId, clientId: newClient.id)
            await fetchClients(for: ptId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
