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
        try db.collection("users").document(user.id).setData(from: user, merge: true)
    }

    func fetchUserProfile(id: String) async throws -> UserProfile? {
        let snap = try await db.collection("users").document(id).getDocument()
        guard snap.exists else {
            print("⚠️ No user profile found for id: \(id)")
            return nil
        }
        return try snap.data(as: UserProfile.self)
    }

    func ensureUserProfileExists(
        uid: String,
        displayName: String?,
        role: UserRole = .client
    ) async throws -> UserProfile {
        if let existing = try await fetchUserProfile(id: uid) {
            return existing
        } else {
            let safeName: String
            if let name = displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
                safeName = name
            } else {
                safeName = "User"
            }

            let profile = UserProfile(
                id: uid,
                displayName: safeName,
                role: role,
                linkedClientIds: [],
                linkedPTIds: [],
                timezoneID: TimeZone.current.identifier
            )

            try await createUserProfile(user: profile)
            return profile
        }
    }

    func setUserRole(uid: String, role: UserRole) async throws {
        try await db.collection("users").document(uid).updateData(["role": role.rawValue])
    }

    // MARK: - Plans

    func saveWorkoutPlan(_ plan: WeeklyPlan, for userId: String) async throws {
        let planRef = db.collection("users").document(userId).collection("plans").document(plan.id)
        try planRef.setData(from: plan, merge: true)
    }

    func fetchPlans(for userId: String) async throws -> [WeeklyPlan] {
        let snapshot = try await db.collection("users").document(userId).collection("plans").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: WeeklyPlan.self) }
    }

    // MARK: - Links

    func linkClient(ptId: String, clientId: String) async throws {
        let rel: [String: Any] = [
            "ptId": ptId,
            "clientId": clientId,
            "status": "active"
        ]
        try await db.collection("links").addDocument(data: rel)
    }

    func fetchClients(for ptId: String) async throws -> [ClientLink] {
        let snapshot = try await db.collection("links")
            .whereField("ptId", isEqualTo: ptId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: ClientLink.self) }
    }
}
