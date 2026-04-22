//
//  FocusFlowV2App.swift
//  FocusFlowV2
//
//  Created by Michael Isbell on 4/21/26.
//

import SwiftUI
import SwiftData

@main
struct FocusFlowV2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            UserSettings.self,
            ScheduledSlot.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
