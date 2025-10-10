//
//  AppRootView.swift
//  PT-App
//
//  Created by David Cole on 08/10/2025.
//


import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var store: PlanStore

    var body: some View {
        Group {
            if !session.isSignedIn {
                AuthView()  // ← show Firebase auth when logged out
            } else {
                TabView {
                    // Client home
                    ClientHomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }

                    // Plan editor (personal)
                    NavigationStack {
                        WeeklyPlanEditorView(initial: store.plan) { newPlan in
                            store.save(plan: newPlan)
                        }
                        .navigationTitle("My Plan")
                    }
                    .tabItem { Label("Plan", systemImage: "calendar") }

                    // PT dashboard tab only if user is PT or Both
                    if session.role == .pt || session.role == .both {
                        ClientsListView()
                            .tabItem { Label("Clients", systemImage: "person.3.fill") }
                        TemplatesListView()
                            .tabItem { Label("Templates", systemImage: "doc.on.doc") }
                    }

                    ProfileView()
                        .tabItem { Label("Me", systemImage: "person.crop.circle") }
                }
            }
        }
    }
}
