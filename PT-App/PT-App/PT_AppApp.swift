import SwiftUI

@main
struct PT_AppApp: App {
    @StateObject private var store = PlanStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
