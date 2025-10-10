//
//  ClientsListView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

struct ClientsListView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var clientStore: ClientStore

    var body: some View {
        NavigationStack {
            Group {
                if clientStore.clients.isEmpty {
                    VStack(spacing: 12) {
                        Text("No clients yet.")
                            .foregroundStyle(.secondary)
                        Button {
                            Task {
                                if let ptId = session.user?.id {
                                    await clientStore.addClient(for: ptId, displayName: "New Client")
                                }
                            }
                        } label: {
                            Label("Add a client (demo)", systemImage: "person.badge.plus")
                        }
                        .tint(.green)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        Section("Your Clients") {
                            ForEach(clientStore.clients, id: \.id) { client in
                                NavigationLink(
                                    destination: ClientDetailView(clientId: client.id) // expects String id
                                ) {
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text(String(client.displayName.prefix(1)))
                                                    .font(.caption)
                                                    .foregroundStyle(.white)
                                            )
                                        Text(client.displayName)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle("Clients")   // ← attach to NavigationStack
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if let ptId = session.user?.id {
                            await clientStore.addClient(for: ptId, displayName: "New Client")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            if let ptId = session.user?.id {
                await clientStore.fetchClients(for: ptId)
            }
        }
    }
}

#Preview {
    ClientsListView()
        .environmentObject(SessionStore())
        .environmentObject(ClientStore())
        .preferredColorScheme(.dark)
}
