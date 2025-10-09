//
//  ClientDetailView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

/// Placeholder: in the cloud version this will load the client's assigned plan.
/// For now, it just shows a read-only message and a button to "assign" by opening the editor.
struct ClientDetailView: View {
    @EnvironmentObject private var store: PlanStore
    let clientId: String

    @State private var showingAssign = false

    var body: some View {
        List {
            Section {
                Text("Client ID: \(clientId)")
                    .foregroundStyle(PT.textSub)
                Text("Assigned plan: (local demo)").foregroundStyle(PT.textSub)
            }

            Section {
                Button {
                    showingAssign = true
                } label: {
                    Label("Assign / Edit Plan", systemImage: "calendar.badge.plus")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom))
        .navigationTitle("Client")
        .sheet(isPresented: $showingAssign) {
            NavigationStack {
                WeeklyPlanEditorView(initial: store.plan) { newPlan in
                    // In cloud mode, assign to this clientId and save remotely.
                    store.save(plan: newPlan)
                }
                .navigationTitle("Assign Plan")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Close") { showingAssign = false } }
                }
            }
        }
    }
}