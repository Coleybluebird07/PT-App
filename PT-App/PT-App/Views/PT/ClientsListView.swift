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
            List {
                if clientStore.clients.isEmpty {
                    Section {
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
                } else {
                    Section("Your Clients") {
                        ForEach(clientStore.clients, id: \.id) { client in
                            NavigationLink {
                                ClientDetailView(client: client)
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 32, height: 32)
                                        .overlay(Text(client.displayName.prefix(1)))
                                    Text(client.displayName)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Clients")
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
}

#Preview {
    ClientsListView()
        .environmentObject(SessionStore())
        .environmentObject(ClientStore())
        .preferredColorScheme(.dark)
}
