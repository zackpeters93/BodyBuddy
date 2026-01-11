// BodyBuddyWatchApp.swift
// Main entry point for watchOS app

import SwiftUI

@main
struct BodyBuddyWatchApp: App {
    @StateObject private var appState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
