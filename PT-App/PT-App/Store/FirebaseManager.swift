//
//  FirebaseManager.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() { }

    let db = Firestore.firestore()

    // MARK: - User Management

    func createUserProfile(user: UserProfile) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }

    func fetchUserProfile(id: String) async throws -> UserProfile? {
        let doc = try await db.collection("users").document(id).getDocument()
        return try doc.data(as: UserProfile.self)
    }

    // MARK: - Plans
    func saveWorkoutPlan(_ plan: WeeklyPlan, for userId: String) async throws {
        let planRef = db.collection("users").document(userId).collection("plans").document(plan.id)
        try planRef.setData(from: plan)
    }

    func fetchPlans(for userId: String) async throws -> [WeeklyPlan] {
        let snapshot = try await db.collection("users").document(userId).collection("plans").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: WeeklyPlan.self) }
    }

    // MARK: - Links
    func linkClient(ptId: String, clientId: String) async throws {
        let rel = ["ptId": ptId, "clientId": clientId, "status": "active"]
        try await db.collection("links").addDocument(data: rel)
    }

    func fetchClients(for ptId: String) async throws -> [ClientLink] {
        let snapshot = try await db.collection("links")
            .whereField("ptId", isEqualTo: ptId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: ClientLink.self) }
    }
    
    // MARK: - Auth Helpers

    func ensureUserProfileExists(uid: String,
                                 displayName: String,
                                 role: UserRole = .client) async throws -> UserProfile {
        if let existing = try await fetchUserProfile(id: uid) {
            return existing
        } else {
            var profile = UserProfile(id: uid, displayName: displayName, role: role)
            try await createUserProfile(user: profile)
            return profile
        }
    }

    func setUserRole(uid: String, role: UserRole) async throws {
        try await db.collection("users").document(uid).updateData(["role": role.rawValue])
    }
}
