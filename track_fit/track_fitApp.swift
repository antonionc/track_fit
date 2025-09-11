//
//  track_fitApp.swift
//  track_fit
//
//  Created by Antonio Navarro Cano on 11/9/25.
//

import SwiftUI

@main
struct track_fitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
