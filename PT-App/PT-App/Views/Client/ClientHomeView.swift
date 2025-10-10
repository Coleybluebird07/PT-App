//
//  ClientHomeView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

struct ClientHomeView: View {
    @EnvironmentObject private var store: PlanStore
    @State private var editorKind: PlanEditorKind? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [PT.bgTop, PT.bgBottom], startPoint: .top, endPoint: .bottom)
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
                            Button(action: { editorKind = .edit }) { Label("Edit plan", systemImage: "pencil") }
                            Button(action: { editorKind = .new })  { Label("New plan",  systemImage: "calendar.badge.plus") }
                            Button(role: .destructive) { showDeleteConfirm = true } label: { Label("Delete plan", systemImage: "trash") }
                        } label: { Image(systemName: "ellipsis.circle") }
                    }
                }
            }
            .confirmationDialog("Delete current plan?",
                                isPresented: $showDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete plan", role: .destructive) { store.deletePlan(); Haptics.error() }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(item: $editorKind) { kind in
                WeeklyPlanEditorView(
                    initial: kind == .edit ? store.plan : nil,
                    onSave: { newPlan in Haptics.success(); store.save(plan: newPlan) }
                )
            }
        }
    }
}

enum PlanEditorKind: Identifiable { case new, edit; var id: Int { self == .new ? 0 : 1 } }

#Preview {
    ClientHomeView().environmentObject(PlanStore())
        .preferredColorScheme(.dark)
}
