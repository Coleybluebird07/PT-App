import SwiftUI
import Firebase

@main
struct PT_AppApp: App {
    @StateObject private var store = PlanStore()
    @StateObject private var session = SessionStore()
    @StateObject private var clientStore = ClientStore()   // 👈 add this

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(store)
                .environmentObject(session)
                .environmentObject(clientStore)            // 👈 pass it down
        }
    }
}

