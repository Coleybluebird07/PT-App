//
//  ContentView.swift
//  PT-App
//
//  Created by David Cole on 04/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PlanStore
    @State private var editorKind: PlanEditorKind? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(white: 0.08)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                if let today = store.todayPlanIfUsable {
                    TodayView(
                        today: today,
                        onEdit: { editorKind = .edit },
                        onNew:  { editorKind = .new },
                        onDelete: { showDeleteConfirm = true }
                    )
                    .padding(.horizontal, 20)
                } else {
                    NoPlanView(onAdd: { editorKind = .new })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .navigationTitle("PT-App")
            .toolbar {
                if store.hasUsablePlan {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Edit plan")  { editorKind = .edit }
                            Button("New plan")   { editorKind = .new }
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Text("Delete plan")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .confirmationDialog("Delete current plan?",
                                isPresented: $showDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete plan", role: .destructive) { store.deletePlan() }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(item: $editorKind) { kind in
                WeeklyPlanEditorView(
                    initial: kind == .edit ? store.plan : nil,
                    onSave: { newPlan in store.save(plan: newPlan) }
                )
            }
        }
    }
}

// For presenting the editor as a sheet
enum PlanEditorKind: Identifiable {
    case new, edit
    var id: Int { self == .new ? 0 : 1 }
}

#Preview {
    ContentView().environmentObject(PlanStore())
}
