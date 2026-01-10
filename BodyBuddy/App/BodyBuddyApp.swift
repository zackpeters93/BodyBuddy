// BodyBuddyApp.swift
// Main entry point for the BodyBuddy iOS app

import SwiftUI
import BodyBuddyCore

@main
struct BodyBuddyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
