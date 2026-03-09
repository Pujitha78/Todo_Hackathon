import SwiftUI
internal import CoreData

@main
struct TodayTodoApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
