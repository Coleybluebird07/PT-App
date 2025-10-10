//
//  TemplatesListView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

struct TemplatesListView: View {
    @State private var showingNew = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("No templates yet.")
                        .foregroundStyle(PT.textSub)
                    Button {
                        showingNew = true
                    } label: {
                        Label("Create Template", systemImage: "doc.badge.plus")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom))
            .navigationTitle("Templates")
            .sheet(isPresented: $showingNew) {
                NavigationStack {
                    // For now this just opens the same editor and doesn't persist separately.
                    WeeklyPlanEditorView(initial: nil) { _ in
                        // Save to a template store when we add backend.
                    }
                    .navigationTitle("New Template")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Close") { showingNew = false } }
                    }
                }
            }
        }
    }
}