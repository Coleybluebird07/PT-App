//
//  SessionStore.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI
import Combine
import Foundation
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published var user: UserProfile? = nil
    @Published var authError: String? = nil
    @Published var isBusy: Bool = false

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        // Observe Firebase Auth changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            Task { await self?.handleAuthChange(user: fbUser) }
        }
    }

    deinit {
        if let h = authListener { Auth.auth().removeStateDidChangeListener(h) }
    }

    // MARK: - Derived
    var isSignedIn: Bool { user != nil }
    var role: UserRole? { user?.role }

    // MARK: - Public API

    func signUp(email: String, password: String, displayName: String, role: UserRole) async {
        authError = nil; isBusy = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            _ = try await FirebaseManager.shared.ensureUserProfileExists(uid: uid,
                                                                         displayName: displayName.isEmpty ? emailPrefix(email) : displayName,
                                                                         role: role)
            try await result.user.updateProfile(\.displayName, to: displayName.isEmpty ? emailPrefix(email) : displayName)
        } catch {
            authError = error.localizedDescription
        }
        isBusy = false
    }

    func signIn(email: String, password: String) async {
        authError = nil; isBusy = true
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            authError = error.localizedDescription
        }
        isBusy = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    func setRole(_ newRole: UserRole) {
        guard var u = user else { return }
        u.role = newRole
        self.user = u
        Task { try? await FirebaseManager.shared.setUserRole(uid: u.id, role: newRole) }
    }

    // MARK: - Private

    private func handleAuthChange(user fbUser: FirebaseAuth.User?) async {
        guard let fbUser = fbUser else {
            self.user = nil
            return
        }
        // Load or create the Firestore profile
        do {
            if let profile = try await FirebaseManager.shared.fetchUserProfile(id: fbUser.uid) {
                self.user = profile
            } else {
                let profile = try await FirebaseManager.shared.ensureUserProfileExists(
                    uid: fbUser.uid,
                    displayName: fbUser.displayName ?? emailPrefix(fbUser.email ?? "User"),
                    role: .client
                )
                self.user = profile
            }
        } catch {
            self.authError = error.localizedDescription
        }
    }

    private func emailPrefix(_ email: String) -> String {
        email.split(separator: "@").first.map(String.init) ?? "User"
    }
}

extension FirebaseAuth.User {
    func updateProfile(_ keyPath: WritableKeyPath<UserProfileChangeRequest, String?>, to value: String?) async throws {
        var request = createProfileChangeRequest() // ← change 'let' to 'var'
        request[keyPath: keyPath] = value
        try await request.commitChanges()
    }
}
