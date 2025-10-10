//
//  SessionStore.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//

import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published var user: UserProfile?
    @Published var authError: String?
    @Published var isBusy: Bool = false
    @Published var showingSignUp: Bool = false

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            guard let self else { return }
            Task { await self.handleAuthChange(user: fbUser) }
        }
    }

    deinit {
        if let h = authListener { Auth.auth().removeStateDidChangeListener(h) }
    }

    var isSignedIn: Bool { user != nil }
    var role: UserRole? { user?.role }

    // MARK: - Auth

    func signIn(email: String, password: String) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            authError = error.localizedDescription
            print("❌ Sign-in failed:", error.localizedDescription)
        }
    }

    func signUp(email: String, password: String, displayName: String?, role: UserRole) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            // Handle display name
            let safeName: String
            if let name = displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
                safeName = name
            } else {
                safeName = email.split(separator: "@").first.map(String.init) ?? "User"
            }

            // Update Firebase Auth profile
            var change = result.user.createProfileChangeRequest()
            change.displayName = safeName
            try await change.commitChanges()

            // Create or fetch Firestore user profile
            let profile = try await FirebaseManager.shared.ensureUserProfileExists(
                uid: uid,
                displayName: safeName,
                role: role
            )

            self.user = profile
            print("✅ Account created successfully for:", safeName)

        } catch {
            authError = error.localizedDescription
            print("❌ Sign-up failed:", error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    // MARK: - Auth Change Listener

    private func handleAuthChange(user fbUser: FirebaseAuth.User?) async {
        guard let fbUser else {
            self.user = nil
            return
        }

        do {
            let uid = fbUser.uid
            let name = fbUser.displayName ?? "User"
            let profile = try await FirebaseManager.shared.ensureUserProfileExists(
                uid: uid,
                displayName: name,
                role: .client
            )
            self.user = profile
        } catch {
            authError = error.localizedDescription
            print("⚠️ Auth change handling failed:", error.localizedDescription)
        }
    }
}
