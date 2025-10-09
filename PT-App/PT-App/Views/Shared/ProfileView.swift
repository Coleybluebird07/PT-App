//
//  ProfileView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text("Name: \(session.user?.displayName ?? "—")")
                    Text("Role: \(session.role?.displayName ?? "—")")
                }

                Section("Role") {
                    Picker("Active role", selection: Binding(
                        get: { session.role ?? .client },
                        set: { session.setRole($0) }
                    )) {
                        ForEach(UserRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }

                Section("Links (demo)") {
                    if session.role == .client || session.role == .both {
                        Button {
                            session.linkToPT(displayName: "Coach")
                            Haptics.success()
                        } label: { Label("Link to a PT (demo)", systemImage: "person.crop.circle.badge.plus") }
                    }
                    if session.role == .pt || session.role == .both {
                        Button {
                            session.addClient(displayName: "Client")
                            Haptics.success()
                        } label: { Label("Add a client (demo)", systemImage: "person.fill.badge.plus") }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        session.signOut()
                        Haptics.warning()
                    } label: { Text("Sign out") }
                }
            }
            .scrollContentBackground(.hidden)
            .background(LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom))
            .navigationTitle("Me")
        }
    }
}