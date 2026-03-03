//
//  track_fit_Watch_AppApp.swift
//  track_fit Watch App Watch App
//
//  Created by Antonio Navarro Cano on 2/3/26.
//

import SwiftUI

@main
struct track_fit_Watch_App_Watch_AppApp: App {
    @StateObject private var healthManager = WatchHealthManager()
    
    init() {
        _ = WatchSessionManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
        }
    }
}
