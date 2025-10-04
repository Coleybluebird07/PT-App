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

                if let today = store.todayPlan {
                    // --- After a plan exists: show today ---
                    TodayView(today: today,
                              onEdit: { editorKind = .edit },
                              onNew:  { editorKind = .new },
                              onDelete: { showDeleteConfirm = true })
                    .padding(.horizontal, 20)
                } else {
                    // --- First launch: only the CTA ---
                    VStack(spacing: 16) {
                        Text("Welcome")
                            .font(.largeTitle.weight(.semibold))
                        Text("Create your weekly workout plan to get started.")
                            .foregroundStyle(.secondary)
                        Button {
                            editorKind = .new
                        } label: {
                            Text("Make a workout plan")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("PT-App")
            .toolbar {
                if store.plan != nil {
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
                    onSave: { newPlan in
                        store.save(plan: newPlan)
                    }
                )
            }
        }
    }
}

// Which editor to show (new vs. edit)
enum PlanEditorKind: Identifiable {
    case new, edit
    var id: Int { self == .new ? 0 : 1 }
}

// View shown when a plan exists
private struct TodayView: View {
    let today: DayPlan
    let onEdit: () -> Void
    let onNew: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Today: \(today.weekday.rawValue)")
                .font(.title2.weight(.semibold))

            if today.isWorkoutDay {
                Text("You have a workout today")
                    .font(.headline)

                if today.exercises.isEmpty {
                    Text("No exercises added to today yet.")
                        .foregroundStyle(.secondary)
                } else {
                    // Show exercises planned for today
                    VStack(spacing: 10) {
                        ForEach(today.exercises) { ex in
                            ExerciseRow(exercise: ex)
                        }
                    }
                }
            } else {
                Text("Rest day")
                    .font(.headline)
                Text("No workout scheduled.")
                    .foregroundStyle(.secondary)
            }

            // Quick manage actions
            HStack {
                Button("Edit plan", action: onEdit)
                Spacer()
                Button("New plan", action: onNew)
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Text("Delete plan")
                }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
        )
    }
}
