//
//  ProfileView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var clientStore: ClientStore

    var body: some View {
        NavigationStack {
            List {
                // MARK: Account Section
                Section("Account") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.user?.displayName ?? "Signed in")
                            .font(.headline)
                        Text(session.user?.id ?? "")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }

                // MARK: Role Section
                if let currentRole = session.role {
                    Section("Role") {
                        Picker("Active role", selection: Binding<UserRole>(
                            get: { currentRole },
                            set: { newRole in
                                Task {
                                    await updateUserRole(to: newRole)
                                }
                            }
                        )) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                Text(role.displayName).tag(role)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // MARK: Links (Demo)
                Section("Links (demo)") {
                    if session.role == .client || session.role == .both {
                        Button("Link to PT (Demo)") {
                            Task {
                                await demoLinkClientToPT()
                            }
                        }
                    }
                }

                // MARK: Sign Out
                Section {
                    Button(role: .destructive) {
                        session.signOut()
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    // MARK: - Helper Methods

    private func updateUserRole(to newRole: UserRole) async {
        guard let uid = session.user?.id else { return }
        do {
            try await FirebaseManager.shared.setUserRole(uid: uid, role: newRole)
            session.user?.role = newRole
        } catch {
            print("⚠️ Failed to update role:", error.localizedDescription)
        }
    }

    private func demoLinkClientToPT() async {
        guard let clientId = session.user?.id else { return }

        let pt = UserProfile(id: UUID().uuidString,
                             displayName: "Demo PT",
                             role: .pt)
        do {
            try await FirebaseManager.shared.createUserProfile(user: pt)
            try await FirebaseManager.shared.linkClient(ptId: pt.id, clientId: clientId)
            print("✅ Linked demo PT to client successfully")
        } catch {
            print("⚠️ Failed to link client to PT:", error.localizedDescription)
        }
    }
}
